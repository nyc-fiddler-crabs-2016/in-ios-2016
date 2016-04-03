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

class NewConversationViewController: UIViewController {
    
    @IBOutlet weak var expirationDate: UIDatePicker!
    @IBOutlet weak var conversationName: UITextField!
    
    
    // MARK: Properties
    var ref: Firebase!
    var conversationRef: Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url: "https://flickering-heat-6121.firebaseio.com")
        conversationRef = ref.childByAppendingPath("conversations")
    }
    
    @IBAction func newConversationDidTouch(sender: AnyObject) {
        ref.authAnonymouslyWithCompletionBlock { (error, authData) in
            if error != nil { print(error.description); return }
            self.performSegueWithIdentifier("createConvo", sender: nil)
        }

        
    }
   
    @IBAction func showAllContacts(sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(self.expirationDate.date)
        super.prepareForSegue(segue, sender: sender)
        let navVc = segue.destinationViewController as! UINavigationController
        print(String(navVc.viewControllers.first!.classForCoder))
        let ConversationViewControllerStr = "ConversationViewController"
        if String(navVc.viewControllers.first!.classForCoder) == ConversationViewControllerStr {
            let chatVc = navVc.viewControllers.first as! ConversationViewController
            chatVc.senderId = "1e7110ff-86b9-442b-85b7-b225749875b2"
            chatVc.senderDisplayName = "peter"
            let dateStr = self.expirationDate.date as NSDate
            let itemRef = conversationRef.childByAutoId()
            let conversationItem = [
                "name": self.conversationName.text,
                "owner": chatVc.senderId,
                "date": String(dateStr)
            ]
            itemRef.setValue(conversationItem)
            chatVc.conversationKey = itemRef.key
        }
    }
    
}