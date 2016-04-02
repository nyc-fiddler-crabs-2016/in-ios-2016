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
    
    // MARK: Properties
    var ref: Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url: "https://flickering-heat-6121.firebaseio.com")
    }
    //@IBOutlet weak var addContacts: UIBarButtonItem!
    
    @IBAction func newConversationDidTouch(sender: AnyObject) {
        ref.authAnonymouslyWithCompletionBlock { (error, authData) in
            if error != nil { print(error.description); return }
            self.performSegueWithIdentifier("LoginToChat", sender: nil)
        }

        
    }
    
    @IBAction func showAllContacts(sender: AnyObject) {
            let contactPickerViewController = CNContactPickerViewController()
            presentViewController(contactPickerViewController, animated: true, completion: nil)
        
    }
    
    
    
    
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        super.prepareForSegue(segue, sender: sender)
//        let navVc = segue.destinationViewController as! UINavigationController
//        let chatVc = navVc.viewControllers.first as! ConversationViewController
//        chatVc.senderId = ref.authData.uid
//        chatVc.senderDisplayName = ""
//    }
    
}




/* 
@IBAction func navToNewConversationForm() {
    self.performSegueWithIdentifier("toNewConversationForm", sender: self)
}
 */