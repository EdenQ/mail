//
//  MailSendViewController.swift
//  Linktel Mail
//
//  Created by  Eden on 2015/12/3.
//  Copyright © 2015年 administrator. All rights reserved.
//

import UIKit

class MailSendViewController: UIViewController {
    
    @IBOutlet weak var from: UILabel!
    
    @IBOutlet weak var to: UITextField!
    
    @IBOutlet weak var subject: UITextField!
    
    @IBOutlet weak var content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        from.text = smtpSession.username
        // Do any additional setup after loading the view.
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

    @IBAction func send(sender: AnyObject) {
        var builder = MCOMessageBuilder()
        builder.header.from = MCOAddress(mailbox: from.text)
        builder.header.to = [MCOAddress(mailbox: to.text)]
        builder.header.subject = subject.text
        builder.htmlBody = content.text
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperationWithData(rfc822Data)
        sendOperation.start({error in
            if (error != nil) {
               print("Error sending email: \(error)")
            } else {
                print("Successfully sent email!")
            }
        })
        self.navigationController!.popViewControllerAnimated(true)
        
    }
}
