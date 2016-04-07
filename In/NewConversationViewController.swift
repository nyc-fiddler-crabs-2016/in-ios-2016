//
//  NewConversationViewController.swift
//  In
//
//  Created by Apprentice on 4/2/16.
//  Copyright © 2016 Ryan F. Salerno. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import ContactsUI
import Contacts
import MessageUI
import Alamofire


class NewConversationViewController: UIViewController, CNContactPickerDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var expirationDate: UIDatePicker!

    
    
    @IBOutlet weak var conversationName: UITextField!
    
    @IBAction func userTappedBackground(sender: AnyObject) {
        view.endEditing(true)
    }
    
    
    // MARK: Properties
    var ref: Firebase!
    var conversationRef: Firebase!
    var usersRef: Firebase!
    var myPhoneNumber: String!
    var myDisplayName: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url: "https://flickering-heat-6121.firebaseio.com")
        conversationRef = ref.childByAppendingPath("conversations")
        usersRef = ref.childByAppendingPath("users")
        let calendar = NSCalendar.currentCalendar()
        let minuteFromNow = calendar.dateByAddingUnit(.Minute, value: 1, toDate: NSDate(), options: [])
        
        expirationDate.minimumDate = minuteFromNow
        
        // Return my phone number to self.myPhoneNumber
        usersRef.queryOrderedByChild("uid").queryEqualToValue(ref.authData.uid)
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                self.myPhoneNumber = snapshot.value["phoneNumber"] as! String
                self.myDisplayName = snapshot.value["displayName"] as! String
        })
    }
    
    @IBAction func newConversationDidTouch(sender: AnyObject) {
        ref.authAnonymouslyWithCompletionBlock { (error, authData) in
            if error != nil { print(error.description); return }
            self.performSegueWithIdentifier("createConvo", sender: nil)
        }
        
        
    }
    var selectedContact = [String]()
    var contactsArray = [String]()
    
    @IBOutlet weak var showParticipant: UILabel!

    //returns selected contact
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact){

        var selectedNumber = ""
        
        if (contact.isKeyAvailable(CNContactPhoneNumbersKey)) {
            for phoneNumber:CNLabeledValue in contact.phoneNumbers {

                if (phoneNumber.label == "_$!<Mobile>!$_" || phoneNumber.label == "iPhone"){
                    
                    let a = phoneNumber.value as! CNPhoneNumber
                    selectedNumber = a.stringValue
                    var almostFormattedNumber = selectedNumber.componentsSeparatedByCharactersInSet(
                        NSCharacterSet.decimalDigitCharacterSet().invertedSet)
                    
                    print("----")
                    print(almostFormattedNumber)
                    
                    if almostFormattedNumber[1] == "1" && almostFormattedNumber[0] == ""{
                        almostFormattedNumber.removeAtIndex(1)
                    }
                    
                    print(almostFormattedNumber)
                    
                    let formattedNumber = almostFormattedNumber.joinWithSeparator("")
                    usersRef.observeEventType(.Value, withBlock: { snapshot in
                        
                        
                        if snapshot.hasChild(formattedNumber) {
                            self.selectedContact.append(("\(contact.givenName) \(contact.familyName)"))
                            self.showParticipant.text = self.selectedContact.joinWithSeparator(", ")
                            if !self.contactsArray.contains(formattedNumber) {
                                self.contactsArray.append(formattedNumber)
                            }
                            print(self.selectedContact)
                            
                        } else {
                            // send text to Katie Bell
                            if (MFMessageComposeViewController.canSendText()) {
                                let controller = MFMessageComposeViewController()
                                let emoji = "\u{1F913}"
                                controller.body = "This app is sweet, you should download it \(emoji)  http://devbootcamp.com/in-ios"
                                controller.recipients = ["\(formattedNumber)"]
                                controller.messageComposeDelegate = self
                                self.presentViewController(controller, animated: true, completion: nil)
                            }
                            print("Not in database")
                        }
                    })
                }
                
            }
        }
        
    }
    
    
    @IBAction func showAllContacts(sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navVc = segue.destinationViewController as! UINavigationController
//        print(String(navVc.viewControllers.first!.classForCoder))
        let ConversationViewControllerStr = "ConversationViewController"
        if String(navVc.viewControllers.first!.classForCoder) == ConversationViewControllerStr {
            let chatVc = navVc.viewControllers.first as! ConversationViewController
            chatVc.senderId = ref.authData.uid
            chatVc.senderDisplayName = self.myDisplayName

            let dateStr = self.expirationDate.date as NSDate
            let itemRef = conversationRef.childByAutoId()
            
            self.contactsArray.append(self.myPhoneNumber)
            // adds your number as a participant in the conversation (contactsArray) by default
            
            let conversationItem:Dictionary<String, AnyObject> = [
                "name": self.conversationName.text!,
                "owner": chatVc.senderId,
                "date": String(dateStr),
                "participants": contactsArray as NSArray
            ]
            //for every item in contactsArray, query database for matching user account (by phone number) and retrieve token
            //convert token
            //send notification about new convo to everyone in array except for index 0
            var user : Firebase!

            itemRef.setValue(conversationItem)
            chatVc.conversationKey = itemRef.key
            
            let parameters = ["conv_id":itemRef.key,"type":"conversation"]
            Alamofire.request(.POST, "https://cryptic-river-41640.herokuapp.com/notifications",parameters: parameters)
            
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}