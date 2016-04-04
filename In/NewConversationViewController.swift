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
//    @IBOutlet weak var showParticipant: UILabel!
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
                }
            }
        }
        selectedContact["\(contact.givenName)"] = ("\(contact.givenName) \(contact.familyName)")
        
        print(selectedContact)
        showParticipant.text = selectedContact["\(contact.givenName)"]
        
    }
    
    
    @IBAction func showAllContacts(sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navVc = segue.destinationViewController as! UINavigationController
        print(String(navVc.viewControllers.first!.classForCoder))
        let ConversationViewControllerStr = "ConversationViewController"
        if String(navVc.viewControllers.first!.classForCoder) == ConversationViewControllerStr {
            let chatVc = navVc.viewControllers.first as! ConversationViewController
            chatVc.senderId = ref.authData.uid
            chatVc.senderDisplayName = "Joe K"
//            chatVc.senderDisplayName = query firebase for where auth uid == the id, and get back display name
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