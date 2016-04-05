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


class NewConversationViewController: UIViewController, CNContactPickerDelegate {
    
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
    var selectedContact = [String:String]()
    var contactsArray = [String]()
    
    @IBOutlet weak var showParticipant: UILabel!

    //returns selected contact
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact){

        var selectedNumber = ""
        
        if (contact.isKeyAvailable(CNContactPhoneNumbersKey)) {
            for phoneNumber:CNLabeledValue in contact.phoneNumbers {
                if (phoneNumber.label == "_$!<Mobile>!$_" || phoneNumber.label == "_$!<iPhone>!$_"){
                    
                    let a = phoneNumber.value as! CNPhoneNumber
                    selectedNumber = a.stringValue
                    let almostFormattedNumber = selectedNumber.componentsSeparatedByCharactersInSet(
                        NSCharacterSet.decimalDigitCharacterSet().invertedSet)
                    let formattedNumber = almostFormattedNumber.joinWithSeparator("")
                    usersRef.observeEventType(.Value, withBlock: { snapshot in
                        
                        
                        if snapshot.hasChild(formattedNumber) {
                            self.selectedContact["\(formattedNumber)"] = ("\(contact.givenName) \(contact.familyName)")
                            self.showParticipant.text = self.selectedContact["\(formattedNumber)"]
                            if !self.contactsArray.contains(formattedNumber) {
                                self.contactsArray.append(formattedNumber)
                            }
//                            print(self.contactsArray)
                        } else {
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

            for phoneNumber in contactsArray{

                usersRef.childByAppendingPath(phoneNumber).observeEventType(.Value, withBlock: { snapshot in
                    print(snapshot)
                    var token = snapshot.value["deviceToken"] as! String
                    let TokenForAPN : NSData? = NSData(base64EncodedString: token, options: NSDataBase64DecodingOptions(rawValue: 0))
                    // actually send the push notification using NSNotificationCenter
                    
                })
                    

                
                //                user = usersRef.childByAppendingPath(phoneNumber)
//                let token = user.queryEqualToValue("deviceToken")
                print("----------------")
//                print(token)
            }
            
            
            
            
            
            
//            print(self.myDisplayName)
            itemRef.setValue(conversationItem)
            chatVc.conversationKey = itemRef.key
        }
    }
    
}