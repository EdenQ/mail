//
//  MailBox.swift
//  Linktel Mail
//
//  Created by administrator on 2015/10/28.
//  Copyright © 2015年 administrator. All rights reserved.
//

import Foundation

let keychain_item = "LinktelMailTest001"
let kClientID = "142376023110-0fpb9hlh4510i00np10kg3gphe135aqc.apps.googleusercontent.com"
let kClientSecret = "OXmOknYiwnVvtl3fcIjmNv5b"
var imapSession:MCOIMAPSession!
var smtpSession:MCOSMTPSession!
let NUMBER_OF_MESSAGES_TO_LOAD:Int = 10
var totalNumberOfInboxMessages: Int! = 0

class MailBox: NSObject {
    
    var mailListViewController: MailListTableViewController

    var archivedMessages = [MCOIMAPMessage]()
    var unreadMessages = [MCOIMAPMessage]()
    var savedMessages = [MCOIMAPMessage]()
    var archivedContent = [Int: String]()
    
    var mailListMessage = [MCOIMAPMessage]()
    var mailListContent = [UInt32: String]()
    
    var email: String?
    var auth: GTMOAuth2Authentication?
    
    init (owner: MailListTableViewController) {
        mailListViewController = owner
        super.init()
        startOAuth2()
    }
    
    func startOAuth2() {
        // Load authentication from keychain if possible
        let auth: GTMOAuth2Authentication = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(keychain_item, clientID: kClientID, clientSecret: kClientSecret)
        
        if auth.refreshToken == nil {
            let authViewController = GTMOAuth2ViewControllerTouch(scope: "https://mail.google.com", clientID: kClientID, clientSecret: kClientSecret, keychainItemName: keychain_item, delegate: self, finishedSelector: "viewController:finishedWithAuth:error:")
            
            authViewController.title = "Gmail"
            self.mailListViewController.navigationController!.pushViewController(authViewController, animated: true)
            
        } else {
            auth.beginTokenFetchWithDelegate(self, didFinishSelector: "auth:finishedRefreshWithFetcher:error:")
        }
        
    }
    
    func auth(authorization: GTMOAuth2Authentication, finishedRefreshWithFetcher: GTMHTTPFetcher, error: NSError?) {
        viewController(nil, finishedWithAuth: authorization, error: error)
    }
    
    // Dismiss the login modal view controller
    func viewController(vc: GTMOAuth2ViewControllerTouch?, finishedWithAuth: GTMOAuth2Authentication, error: NSError?) {
        if (error != nil) {
            // Authentication failed
        } else {
            // Authentication success
            auth = finishedWithAuth
            vc?.dismissViewControllerAnimated(true, completion: nil)
            email = finishedWithAuth.userEmail
            
            imapSession = MCOIMAPSession()
            imapSession.authType = MCOAuthType.XOAuth2
            imapSession.OAuth2Token = finishedWithAuth.accessToken
            imapSession.username = email
            imapSession.hostname = "imap.gmail.com"
            imapSession.port = 993
            imapSession.connectionType = MCOConnectionType.TLS
            
            smtpSession = MCOSMTPSession()
            smtpSession.authType = MCOAuthType.XOAuth2
            smtpSession.OAuth2Token = finishedWithAuth.accessToken
            smtpSession.username = email
            smtpSession.hostname = "smtp.gmail.com"
            smtpSession.port = 465
            smtpSession.connectionType = MCOConnectionType.TLS

            totalNumberOfInboxMessages = -1
            self.mailListViewController.loadMoreActivityView.startAnimating()

            self.mailListContent.removeAll()
            self.mailListMessage.removeAll()
            self.mailListViewController.inboxTableView.reloadData()
            
            fetchMailList(NUMBER_OF_MESSAGES_TO_LOAD)
        }
    }
    
    // Logout
    func logout() {
        self.mailListContent.removeAll()
        self.mailListMessage.removeAll()
        self.mailListViewController.inboxTableView.reloadData()
        
        GTMOAuth2ViewControllerTouch.removeAuthFromKeychainForName(keychain_item)
        GTMOAuth2ViewControllerTouch.revokeTokenForGoogleAuthentication(auth)
        startOAuth2()
    }
    
    //取得Mail list
    func fetchMailList(nMessages:Int) {
        
        var count:Int = 0
        let requestKind: MCOIMAPMessagesRequestKind = [.Headers, .Flags, .FullHeaders]
        let uids = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))
        let folder = "INBOX"
        let fetchOperationFolder = imapSession.folderInfoOperation(folder)
        
        fetchOperationFolder.start({error, folderInfo in
            
            let totalNumberOfMessagesDidChange:Bool = totalNumberOfInboxMessages != Int(folderInfo.messageCount)
            //先取得INBOX內有幾筆mail
            totalNumberOfInboxMessages = Int(folderInfo.messageCount)
            
            var numberOfMessagesToLoad:Int = min(totalNumberOfInboxMessages, nMessages)
            
            if numberOfMessagesToLoad == 0 {
                self.mailListViewController.loadMoreActivityView.stopAnimating()
                return;
            }
            
            let fetchRange:MCORange;
            
            // If total number of messages did not change since last fetch,
            // assume nothing was deleted since our last fetch and just
            // fetch what we don't have
            if !totalNumberOfMessagesDidChange && self.mailListMessage.count > 0 {
                numberOfMessagesToLoad -= self.mailListMessage.count;
                
                fetchRange = MCORangeMake(UInt64(totalNumberOfInboxMessages - self.mailListMessage.count - (numberOfMessagesToLoad - 1)),UInt64(numberOfMessagesToLoad - 1));
            }
                // Else just fetch the last N messages
            else {
//                print("\(self.totalNumberOfInboxMessages)")
//                print("\(numberOfMessagesToLoad)")
                fetchRange = MCORangeMake(UInt64(totalNumberOfInboxMessages - (numberOfMessagesToLoad - 1)), UInt64(numberOfMessagesToLoad - 1));
            }

            let fetchOperation = imapSession.fetchMessagesByNumberOperationWithFolder(folder, requestKind: requestKind, numbers: MCOIndexSet(range: fetchRange))
            
//            let fetchOperation = imapSession.fetchMessagesOperationWithFolder(folder, requestKind: requestKind, uids: uids)
            
            fetchOperation.start({error, fetchedMessages, vanishedMessages in
                if (error != nil) {
                    print("Error downloading message headers: \(error)")
                } else {
                    let combinedMessages:NSMutableArray = NSMutableArray()
                    combinedMessages.addObjectsFromArray(fetchedMessages)

                    let timeSortDescriptor = NSSortDescriptor(key: "header.date", ascending: false)

                    let tempMessages = combinedMessages.sortedArrayUsingDescriptors([timeSortDescriptor]) as! [MCOIMAPMessage]
                    
                    for item: AnyObject in tempMessages {

                        let message = item as! MCOIMAPMessage
                        
                        self.mailListMessage.append(message)
                        
                        let fetchOperationMessage = imapSession.fetchMessageOperationWithFolder(folder, uid: message.uid)
                            
                        fetchOperationMessage.start({error, fetchedMessage in
                            
                            let messageParser = MCOMessageParser.init(data: fetchedMessage)
                            let msgBody = messageParser.plainTextBodyRendering()

                            if msgBody.characters.count < 150 {
                                self.mailListContent[message.uid] = msgBody
                            } else {
                                self.mailListContent[message.uid] = msgBody.substringWithRange(Range<String.Index>(start: msgBody.startIndex, end: msgBody.startIndex.advancedBy(150)))
                            }
                            
                            count++
                            if numberOfMessagesToLoad == count {
                                self.mailListViewController.inboxTableView.reloadData()
                                self.mailListViewController.loadMoreActivityView.stopAnimating()
                                
                            }
                        })
                    }
                }
            })
 
        })
        
    }
    
    func fetchMessages(){
        //        fetchUnreadMessages()
        //        fetchSavedMessages()
        fetchArchivedMessages()
    }
    
    //未讀信件
    func fetchUnreadMessages() {
        let requestKind: MCOIMAPMessagesRequestKind = [.Headers, .Flags]
        let folder = "INBOX"
        let uids = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))
        
        let fetchOperation = imapSession.fetchMessagesOperationWithFolder(folder, requestKind: requestKind, uids: uids)
        
        fetchOperation.start({error, fetchedMessages, vanishedMessages in
            if (error != nil) {
                print("Error downloading message headers: \(error)")
            } else {
                for item: AnyObject in fetchedMessages {
                    if (item as! MCOIMAPMessage).flags != MCOMessageFlag.Seen {
                        self.unreadMessages.append(item as! MCOIMAPMessage)
                    }
                }
//                print("\(self.unreadMessages)")
//                self.masterViewController.inboxTableView.reloadData()
            }
        })
    }
    
    //已讀信件
    func fetchSavedMessages() {
        let requestKind:MCOIMAPMessagesRequestKind = [.Headers, .Flags]
        let folder = "INBOX"
        let uids = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))
        
        let fetchOperation = imapSession.fetchMessagesOperationWithFolder(folder, requestKind: requestKind, uids: uids)
        
        fetchOperation.start({error, fetchedMessages, vanishedMessages in
            if (error != nil) {
                print("Error downloading message headers: \(error)")
            } else {
                for item: AnyObject in fetchedMessages {
                    if (item as! MCOIMAPMessage).flags == MCOMessageFlag.Seen {
                        self.savedMessages.append(item as! MCOIMAPMessage)
                    }
                }
//                print("\(self.savedMessages)")
                self.mailListViewController.inboxTableView.reloadData()
            }
        })
        
    }
    
    //所有信件
    func fetchArchivedMessages() -> [MCOIMAPMessage] {
        let requestKind:MCOIMAPMessagesRequestKind = [.Headers, .FullHeaders]
        let folder = "[Gmail]/All Mail"
        let uids = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))
        
        let fetchOperation = imapSession.fetchMessagesOperationWithFolder(folder, requestKind: requestKind, uids: uids)
        
        fetchOperation.start({error, fetchedMessages, vanishedMessages in
            if (error != nil) {
                print("Error downloading message headers: \(error)")
            } else {
                for item: AnyObject in fetchedMessages {
                    var labels = (item as! MCOIMAPMessage).gmailLabels as? [NSString]
                    if labels == nil {
                        labels = []
                    }
                    if !labels!.contains("\\Inbox") {
                        let message = item as! MCOIMAPMessage
                        self.archivedMessages.append(message)
                        self.fetchPreMessageBody(message)
                    }
                }
            }

        })
        
        return self.archivedMessages
    }
    
    //取得信件資料夾
    func fetchFolder() {
        let fetchOperation = imapSession.fetchAllFoldersOperation()
        fetchOperation.start({error, fetchedFolder in
            //print("\(fetchedFolder)")
            
            for item: AnyObject in fetchedFolder {
                let folder = item as! MCOIMAPFolder
                let folderName = imapSession.defaultNamespace.componentsFromPath(folder.path)
//                print("\(folderName)")
            }
            
        })
    }
    
    
    //取得信件內容
    func fetchMessageBody(message: MCOIMAPMessage) {
        let folder = "INBOX"
        let fetchOperation = imapSession.fetchMessageOperationWithFolder(folder, uid: message.uid)
        
        fetchOperation.start({error, fetchedMessage in
            let messageParser = MCOMessageParser.init(data: fetchedMessage)
            let msgHtmlBody = messageParser.htmlBodyRendering()
            print("\(msgHtmlBody)")

        })
    }
    
    //取得預覽信件內容
    func fetchPreMessageBody(message: MCOIMAPMessage) {
        let folder = "[Gmail]/All Mail"

        let fetchOperation = imapSession.fetchMessageOperationWithFolder(folder, uid: message.uid)

        fetchOperation.start({error, fetchedMessage in
            let messageParser = MCOMessageParser.init(data: fetchedMessage)
            let msgBody = messageParser.plainTextBodyRendering()
//            print("\(msgBody)")
            let preMsg = msgBody.substringWithRange(Range<String.Index>(start: msgBody.startIndex, end: msgBody.startIndex.advancedBy(150)))
            self.archivedContent[message.uid.hashValue] = preMsg
//            print("\(preMsg)")
            
            self.mailListViewController.inboxTableView.reloadData()
            self.mailListViewController.loadMoreActivityView.stopAnimating()
            
        })
    }
    
    func saveMessage(message: MCOIMAPMessage) {
        message.flags = [.Seen]
        
        let muid : UInt64 = UInt64(message.uid)
        
        let msgOperation = imapSession.storeFlagsOperationWithFolder("INBOX", uids: MCOIndexSet(index: muid), kind: MCOIMAPStoreFlagsRequestKind.Add, flags: message.flags)
        
        msgOperation.start({error in
            print("selected message flags \(message.flags) UID is \(message.uid)");
        })
    }
    
    func archiveMessage(message: MCOIMAPMessage) {
        let muid : UInt64 = UInt64(message.uid)
        
        let msgOp = imapSession.storeLabelsOperationWithFolder("[Gmail]/All Mail", uids: MCOIndexSet(index: muid), kind: MCOIMAPStoreFlagsRequestKind.Remove, labels: ["\\Inbox"])
        
        msgOp.start({error in
            print("selected message labels \(message.gmailLabels) UID is \(message.uid)");
        })
    }
    
    func sendMessage(message: MCOIMAPMessage) {
        
    }
}