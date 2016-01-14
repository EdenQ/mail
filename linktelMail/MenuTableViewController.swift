//
//  MenuTableViewController.swift
//  linktelMail
//
//  Created by administrator on 2015/10/15.
//  Copyright © 2015年 administrator. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    @IBOutlet var menuTableContent: UITableView!
    
    var menuList:[Menu] = [Menu(name: "Mocha chat", image: "social_icon_u404", identifier: "MailList"),
                            Menu(name: "All inboxes", image: "all_mail_icon_u396", identifier: "MailList"),
                            Menu(name: "Gmail", image: "all_mail_icon_u396", identifier: "MailList"),
                            Menu(name: "Setting", image: "settings_icon_u245", identifier: "Setting"),
                            Menu(name: "About", image: "settings_icon_u245", identifier: "About")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.revealViewController().rearViewRevealOverdraw = 0

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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MenuCell")
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableViewCell

        cell.menuLable!.text = menuList[indexPath.row].name
//            cell.textLabel!.text = menuText

        cell.menuImage!.image = UIImage(named: menuList[indexPath.row].image)
//            cell.imageView!.image = imageName

        
        cell.menuNum!.text = "1"
        
        
        
        //設定指示器
//        switch indexPath.row {
//        case 0:
//            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
//        case 1:
//            cell.accessoryType = UITableViewCellAccessoryType.DetailButton
//        case 2:
//            cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
//        case 3:
//            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//        default:
//            break
//        }


        return cell
    }
    
    
    // 點擊
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        // 換頁
        let identifier = menuList[indexPath.row].identifier
        
        self.performSegueWithIdentifier(identifier, sender: cell)
        
//        tableView.deselectRowAtIndexPath(indexPath, animated: false)
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
    // 傳值
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nav = segue.destinationViewController as! UINavigationController
        let indexPath = self.menuTableContent.indexPathForSelectedRow?.row
        
        if segue.identifier == "About" {
            let aboutView = nav.topViewController as! AboutTableViewController
            aboutView.index = "about"
        } else if segue.identifier == "MailList" {
           let mailListView = nav.topViewController as! MailListTableViewController
            mailListView.mailListTitle = menuList[indexPath!].name
        }
        
    }
    

}
