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

class NewConversationViewController: UIViewController {
    
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

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navVc = segue.destinationViewController as! UINavigationController
        print(navVc.viewControllers.first!.nibName)
        if navVc.viewControllers.first!.nibName == Optional("TTs-EY-WL6-view-1BE-8y-lZM"){
            let chatVc = navVc.viewControllers.first as! ConversationViewController
            chatVc.senderId = ref.authData.uid
            chatVc.senderDisplayName = "peter"

            let itemRef = conversationRef.childByAutoId()
            let conversationItem = [
                "name": "Conversation Name",
                "owner": chatVc.senderId,
                "date": "tomorrow"
            ]
            itemRef.setValue(conversationItem)
            chatVc.conversationKey = itemRef.key
        }
    }
    
}