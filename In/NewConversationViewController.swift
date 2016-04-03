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
    
    
    // MARK: Properties
    var ref: Firebase!
    var conversationRef: Firebase!
    var usersRef: Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url: "https://flickering-heat-6121.firebaseio.com")
        conversationRef = ref.childByAppendingPath("conversations")
        usersRef = ref.childByAppendingPath("users")
    }
    
    @IBAction func newConversationDidTouch(sender: AnyObject) {
        ref.authAnonymouslyWithCompletionBlock { (error, authData) in
            if error != nil { print(error.description); return }
            self.performSegueWithIdentifier("createConvo", sender: nil)
        }

        
    }
    var selectedContact = ["Contact" : String()]
    @IBOutlet weak var showParticipant: UILabel!
    //returns selected contact
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact){
//        print(CNContactPhoneNumbersKey)
        var selectedNumber = ""
        
                if (contact.isKeyAvailable(CNContactPhoneNumbersKey)) {
                    for phoneNumber:CNLabeledValue in contact.phoneNumbers {
                        if (phoneNumber.label == "_$!<Mobile>!$_"){
                            //some people are stored under "iphone" label, add conditional for this after MVP
                            let a = phoneNumber.value as! CNPhoneNumber
                            selectedNumber = a.stringValue
//                            print("\(a.stringValue)")
                        }
                    }
                }
        print(usersRef)
//        selectedContact = "Name: \(contact.givenName) \(contact.familyName)  \nMobile: \(selectedNumber)"
        selectedContact["\(contact.givenName)"] = ("\(contact.givenName) \(contact.familyName) \(selectedNumber)")

        
        print(selectedContact)
        showParticipant.text = selectedContact["\(contact.givenName)"]
        
    }
    
    
    //May be a problem because of the Sender in the line below
//    @IBAction func showPeople(sender:CNContactPickerDelegate){
//        showParticipant.text = "\(selectedContact)"
//    }
//    
    
    
    
    
    @IBAction func showAllContacts(sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // print(self.expirationDate.date)
        super.prepareForSegue(segue, sender: sender)
        let navVc = segue.destinationViewController as! UINavigationController
        print(String(navVc.viewControllers.first!.classForCoder))
        let ConversationViewControllerStr = "ConversationViewController"
        if String(navVc.viewControllers.first!.classForCoder) == ConversationViewControllerStr {
            let chatVc = navVc.viewControllers.first as! ConversationViewController
            chatVc.senderId = "1e7110ff-86b9-442b-85b7-b225749875b2"
            chatVc.senderDisplayName = "peter"
        //Above two values are hard coded but shouldn't be
            let dateStr = self.expirationDate.date as NSDate
            let itemRef = conversationRef.childByAutoId()
            let conversationItem = [
                "name": self.conversationName.text,
                "owner": chatVc.senderId,
                "date": String(dateStr),
                "participant": "test"
            ]
            itemRef.setValue(conversationItem)
            chatVc.conversationKey = itemRef.key
        }
    }
    
}