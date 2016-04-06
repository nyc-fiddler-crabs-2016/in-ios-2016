//
//  ConversationTableViewController.swift
//  In
//
//  Created by Apprentice on 4/3/16.
//  Copyright © 2016 Ryan F. Salerno. All rights reserved.
//

import UIKit
import Firebase
import SwiftMoment


class ConversationTableViewController: UITableViewController {
    var conversations = [Conversation]()
    let conversationRef = Firebase(url: "https://flickering-heat-6121.firebaseio.com/conversations")
    let rootRef = Firebase(url: "https://flickering-heat-6121.firebaseio.com")
    let userRef = Firebase(url: "https://flickering-heat-6121.firebaseio.com/users")
    var conversationKey: String!
    var myPhoneNumber: String!
    var myDisplayName: String!
    
    
    
    
    func loadConversations(){
        
        self.conversationRef.observeEventType(.ChildAdded, withBlock: {snapshot in
            let currentDate = NSDate()
            
            let dateFormatter = NSDateFormatter()
            var dateAsString = snapshot.value["date"] as! String
            dateFormatter.locale = NSLocale.currentLocale()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let newDate = dateFormatter.dateFromString(dateAsString) as! NSDate!
            
            if newDate == newDate.earlierDate(currentDate){
               snapshot.ref.removeValue()
            }
//
            
            
            
            }
            
            )
        
        userRef.queryOrderedByChild("uid").queryEqualToValue(rootRef.authData.uid)
            .observeEventType(.ChildAdded, withBlock: { snapshot in
              
            self.myPhoneNumber = snapshot.value["phoneNumber"] as! String
            self.myDisplayName = snapshot.value["displayName"] as! String
                
            self.conversationRef.queryOrderedByChild("participants").observeEventType(.ChildAdded, withBlock: { snapshot in
            let participants = snapshot.value["participants"] as! NSArray
                for participant in participants {
                    if String(participant) == String(self.myPhoneNumber) {
                        let name = snapshot.value["name"] as! String
                        let owner = snapshot.value["owner"] as! String
                        let date = snapshot.value["date"] as! String
                        let participants = snapshot.value["participants"] as! NSArray
                        let conversation = Conversation(name: name, date: date, owner: owner, conversationId: snapshot.key, participants: participants, mostRecentMessage: NSDate())
                        self.conversations.append(conversation)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                        }
                    }
                }
            })
        })

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadConversations()
        
        

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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return conversations.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cellIdentifier = "ConversationTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ConversationTableViewCell
        
        let conversation = conversations[indexPath.row]
        var selectedContact = [String]()
        for participant in conversation.participants {
            userRef.childByAppendingPath(participant as! String).observeEventType(.Value, withBlock: { snapshot in
//            print(snapshot.value["displayName"] as! String)
            selectedContact.append(snapshot.value["displayName"] as! String)
            let label = cell.conversationLabel as! UILabel
            var participants = cell.participantLabel as! UILabel
            var expiration = cell.expirationTimestamp as! UILabel
            label.text = conversation.name
            participants.text = selectedContact.joinWithSeparator(", ")
            
            let expirationDate = conversation.date as! String
            let dateMoment = moment(expirationDate, dateFormat: "yyyy-MM-dd HH:mm:ss Z")
            expiration.text = "Expires on \(dateMoment!.format("yyyy-MM-dd HH:mm"))"

                
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
//            dateFormatter.dateStyle = .MediumStyle
//            let conversationExpiration = dateFormatter.dateFromString(snapshot.value["date"] as! String) as! NSDate
//            expiration.text = dateFormatter.stringFromDate(conversationExpiration) as! UILabel
            
            })
            
        }
        

        return cell
    }
    

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let conversation = conversations[indexPath.row]
        
        conversationKey = conversation.conversationId
        self.performSegueWithIdentifier("showConversation", sender: rootRef.authData.uid)
        
        
        
        
        
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if editingStyle == .Delete {
            
            var targetDelete = self.conversations[indexPath.row].conversationId
            var firebaseTarget = Firebase(url: "https://flickering-heat-6121.firebaseio.com/conversations/\(targetDelete)")
            self.conversationRef.observeEventType(.ChildAdded, withBlock: {snapshot in
                if snapshot.value["owner"] as! String == self.rootRef.authData.uid && snapshot.key as! String == targetDelete{
                    snapshot.ref.removeValue()
                }
                firebaseTarget.childByAppendingPath("participants").observeEventType(.ChildAdded, withBlock: { snapshot in
                    if snapshot.value as! String == self.myPhoneNumber{
//                        print(snapshot.ref.setValue(nil))
                    }
                    
                })
                
                
            })
            
            self.conversations.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }


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
        
        if String(segue.destinationViewController.classForCoder) == "UINavigationController" {
        let navVc = segue.destinationViewController as! UINavigationController
        let showPage = navVc.viewControllers.first as! ConversationViewController
        showPage.conversationKey = conversationKey
        showPage.senderId = rootRef.authData.uid
        showPage.senderDisplayName = self.myDisplayName
        }
    }


}
