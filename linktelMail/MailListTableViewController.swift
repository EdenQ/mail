//
//  MailListTableViewController.swift
//  linktelMail
//
//  Created by administrator on 2015/10/22.
//  Copyright © 2015年 administrator. All rights reserved.
//

import UIKit
import MessageUI

class MailListTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    var mailbox: MailBox?
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var mailListItem: UINavigationItem!
    
    @IBOutlet var inboxTableView: UITableView!
    
    @IBOutlet weak var loadMoreActivityView: UIActivityIndicatorView!
    
    var mailListTitle:String! = "All Inbox"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadMoreActivityView.hidesWhenStopped = true
        
        //側滑
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        mailListItem.title = mailListTitle
        
        mailbox = MailBox(owner: self)
//        mailbox?.fetchMailList()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("saved row \(mailbox!.savedMessages.count)")

        if section == 1 {
            if totalNumberOfInboxMessages >= 0 {
                return 1
            }
            return 0
        }
        
        return mailbox!.mailListMessage.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        print("\(indexPath.section)")
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("MailCell", forIndexPath: indexPath) as! MailListTableViewCell
            
            //        print("unread \(mailbox!.unreadMessages.count)")
            //        print("saved \(mailbox!.savedMessages.count)")
            //        print("archive \(mailbox!.archivedMessages.count)")
            
            if mailbox?.mailListMessage.count > 0 {
                cell.mailImage!.image = UIImage(named: "u58")
                
                let messageUid = mailbox!.mailListMessage[indexPath.row].uid
                
                cell.mailSender!.text = mailbox?.mailListMessage[indexPath.row].header.sender.displayName
                cell.mailSubject!.text = mailbox?.mailListMessage[indexPath.row].header.subject
                cell.mailContent!.text = mailbox?.mailListContent[messageUid]
                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "yyyy-MM-dd"
                dateFormat.timeZone = NSTimeZone.localTimeZone()
                cell.mailTime!.text = dateFormat.stringFromDate(mailbox!.mailListMessage[indexPath.row].header.date)
                
                
            }
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("MailCell", forIndexPath: indexPath) as! MailListTableViewCell

            print("\(mailbox!.mailListMessage.count)")
            print("\(totalNumberOfInboxMessages)")
            if mailbox!.mailListMessage.count < totalNumberOfInboxMessages {
                mailbox!.fetchMailList(mailbox!.mailListMessage.count + NUMBER_OF_MESSAGES_TO_LOAD)
            }
            cell.mailSender.text = nil
            cell.mailSubject.text = nil
            cell.mailContent.text = nil
            cell.mailImage.image = nil
            cell.mailTime.text = nil
            return cell
            
        default :
            let cell = tableView.dequeueReusableCellWithIdentifier("MailCell", forIndexPath: indexPath) as! MailListTableViewCell

            return cell
        }

    }
    
    
    // 點擊
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            // 換頁
            self.performSegueWithIdentifier("MailContent", sender: cell)
            
            
            //        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        case 1:
            print("case 1")
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        default :
            break
        }
        
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "MailContent" {
            let indexPath = self.inboxTableView.indexPathForSelectedRow?.row
            let nav = segue.destinationViewController as! MailContentViewController
            nav.message = mailbox?.mailListMessage[indexPath!]

//            print("\(mailbox?.mailListMessage[indexPath!].header.sender.displayName)")

        }
        
    }

    @IBAction func logout(sender: AnyObject) {
        mailbox?.logout()
    }

    @IBAction func sendMail(sender: AnyObject) {
        
        
        
//        if MFMailComposeViewController.canSendMail() {
//            
//            let mc = configureMailComposeViewController()
//            
//            self.presentViewController(mc, animated: true, completion: nil)
//            
//        } else {
//            self.showSendMailErrorAlert()
//        }
    }
    
    func configureMailComposeViewController() -> MFMailComposeViewController {
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        
        let emailTitle = "Test from iOS"
        let messageBody = "Hi test"
        let toRecipents = ["edenwork28@gmail.com"]
        
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        return mc
    }
    
    func showSendMailErrorAlert() {
        let alertController = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertAction = UIAlertAction(title: "確定", style: UIAlertActionStyle.Default, handler: nil)
        
        alertController.addAction(alertAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Email Delegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Mail Cancelled")
            
        case MFMailComposeResultSaved.rawValue:
            print("Mail Saved")
            
        case MFMailComposeResultSent.rawValue:
            print("Mail Sent")
            
        case MFMailComposeResultFailed.rawValue:
            print("Mail Failed")
            
        default:
            break
            
        }
        
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
