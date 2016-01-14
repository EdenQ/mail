//
//  MailContentViewController.swift
//  Linktel Mail
//
//  Created by  Eden on 2015/11/13.
//  Copyright © 2015年 administrator. All rights reserved.
//

import UIKit

class MailContentViewController: UIViewController, MCOHTMLRendererIMAPDelegate, UIWebViewDelegate {

    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var mailContent: UIWebView!
    
    var message: MCOIMAPMessage!
    
    var msgHTMLBody: String!
    var mailBodyData: NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mailContent.delegate = self
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.timeZone = NSTimeZone.localTimeZone()

        
        //取得 mail content
        self.fetchMessageBody(message)
        
        subject.text = message.header.subject
        sender.text = message.header.sender.displayName
        time.text = dateFormat.stringFromDate(message.header.date)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //取得信件內容
    func fetchMessageBody(message: MCOIMAPMessage) {
        let folder = "INBOX"

        let fetchOperation = imapSession.fetchMessageOperationWithFolder(folder, uid: message.uid)
        fetchOperation.start({error, fetchedMessage in
            self.mailBodyData = fetchedMessage
            let messageParser = MCOMessageParser.init(data: fetchedMessage)
            self.msgHTMLBody = messageParser.htmlBodyRendering()
            
//            print("\(self.msgHTMLBody)")
            
            let html: NSMutableString = NSMutableString()
            let jsUrl: NSURL = NSBundle.mainBundle().URLForResource("MailScript", withExtension: "js")!
            html.appendFormat("<html><head><script src=\"%@\"></script></head><body>%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'></iframe></html>", jsUrl.absoluteString, self.msgHTMLBody)
            
            self.mailContent.loadHTMLString(html.description, baseURL: nil)
            
        })

    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let responseRequest: NSURLRequest = self.webView(webView, resource: nil, willSendRequest: request, requestredirectResponse: nil, fromDataSource: nil)
        
        if responseRequest == request {
            return true
        } else {
            webView.loadRequest(responseRequest)
            return false
        }
        
    }
    
    func webView(sender: UIWebView, resource identifier:AnyObject?, willSendRequest request: NSURLRequest, requestredirectResponse redirectResponse: NSURLResponse?, fromDataSource dataSource: AnyObject?) -> NSURLRequest {
        
        if request.URL?.scheme == "x-mailcore-msgviewloaded" {
            self.loadImages()
        }
        
        return request
    }

    func loadImages() {
        let result = mailContent.stringByEvaluatingJavaScriptFromString("findCIDImageURL()")
        let data: NSData = (result!.dataUsingEncoding(NSUTF8StringEncoding))!
        do {
            
            let imagesURLStrings: NSArray = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSArray
            
            for urlString in imagesURLStrings {
                var part: MCOAbstractPart?
                let url: NSURL = NSURL(string: urlString as! String)!
                
                if self.isCID(url) {
                    part = self.partForCIDURL(url)
                } else if self.isXMailcoreImage(url) {
                    let partUniqueID = url.resourceSpecifier
                    part = self.partForUniqueID(partUniqueID)
                }
                
                if part == nil {
                    continue
                }

                let partUniqueID: String = part!.uniqueID
                let previewData: NSData = self.dataPartForUniqueID(partUniqueID)
//                let fileName: String = String(format: "%lu", urlString.hash)
//                let cacheURL: NSURL = self.cacheJPEGImageData(previewData, withFilename: fileName)

                let inlineData: String = String(format: "data:image/jpg;base64,%@", previewData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))

                let args: NSDictionary = ["URLKey": urlString, "InlineDataKey": inlineData]
                let jsonString: String = self.jsonEscapedStringFromDictionary(args)
                let replaceScript: String = String(format: "replaceImageSrc(%@)", jsonString)
                mailContent.stringByEvaluatingJavaScriptFromString(replaceScript)
//                print("\(mailContent.stringByEvaluatingJavaScriptFromString("document.body.innerHTML"))")
                
            }
        } catch {
            print("json error: \(error)")
        }
        
        
    }
    
    func isCID(url: NSURL) -> Bool {
       let theScheme: String = url.scheme
        if theScheme.caseInsensitiveCompare("cid") == NSComparisonResult.OrderedSame {
            return true
        }
        return false
    }
    
    func partForCIDURL(url: NSURL) -> MCOAbstractPart {
        let parser: MCOMessageParser = MCOMessageParser(data: self.mailBodyData)
        parser.htmlBodyRendering()
        let attachment = parser.partForContentID(url.resourceSpecifier)
//        return message.partForContentID(url.resourceSpecifier)
        return attachment
    }
    
    func isXMailcoreImage(url: NSURL) -> Bool {
        let theScheme = url.scheme
        if theScheme .caseInsensitiveCompare("x-mailcore-image") == NSComparisonResult.OrderedSame {
            return true
        }
        return false
    }
    
    func partForUniqueID(partUniqueID: String) -> MCOAbstractPart {
        let parser: MCOMessageParser = MCOMessageParser(data: self.mailBodyData)
        parser.htmlBodyRendering()
        let attachment = parser.partForUniqueID(partUniqueID)
//        return message.partForUniqueID(partUniqueID)
        return attachment
    }
    
    
    func dataPartForUniqueID(partUniqueID: String) -> NSData {
        let parser: MCOMessageParser = MCOMessageParser(data: self.mailBodyData)
        parser.htmlBodyRendering()
        let attachment = parser.partForUniqueID(partUniqueID) as! MCOAttachment

        return attachment.data
    }
    
    
    func cacheJPEGImageData(imageDate: NSData, withFilename filename: String) -> NSURL {
        let tmpDirURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
        let fileURL = tmpDirURL.URLByAppendingPathComponent(filename).URLByAppendingPathExtension("jpg")
//        print("FilePath: \(fileURL.path!)")
        
        imageDate.writeToFile(fileURL.path!, atomically: true)
        return fileURL
    }
    
    func jsonEscapedStringFromDictionary(dictionary: NSDictionary) -> String {
        do {
            let json: NSData = try NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
            let jsonString: String = String(data: json, encoding: NSUTF8StringEncoding)!
            
            return jsonString
        } catch {
            return ""
        }
        
    }

}
