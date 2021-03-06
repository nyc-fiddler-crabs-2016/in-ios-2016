//
//  ConversationViewController.swift
//  In
//
//  Created by Apprentice on 4/2/16.
//  Copyright © 2016 Ryan F. Salerno. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
import SwiftMoment
import Alamofire




class ConversationViewController: JSQMessagesViewController {
    
    @IBAction func userTappedBackground(sender: AnyObject) {
        view.endEditing(true)
    }
    
    // MARK: Properties
    let rootRef = Firebase(url: "https://flickering-heat-6121.firebaseio.com/")
    var messageRef: Firebase!
    var messages = [JSQMessage]()
    var conversationKey: String!
    var conversationRef: Firebase!{
    
        
    // Remove media button (paperclip) for now
    self.inputToolbar.contentView.leftBarButtonItem = nil
        
    
    return Firebase(url: "https://flickering-heat-6121.firebaseio.com/conversations/\(conversationKey)")
    }
    var conversationName: String!
    
    var userIsTypingRef: Firebase!
    var usersTypingQuery: FQuery!
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBubbles()
        messageRef = conversationRef.childByAppendingPath("messages")
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        conversationRef.observeEventType(.Value, withBlock: {
            snapshot in
            
            let convDict = snapshot.value as! NSDictionary
            let convName = (convDict.valueForKey("name"))!
            self.title = convName as! String
            let convDate = (convDict.valueForKey("date")) as! String
            let dateMoment = moment(convDate, dateFormat: "yyyy-MM-dd HH:mm:ss Z")
            self.navigationItem.prompt = "Expires on \(dateMoment!.format("yyyy-MM-dd HH:mm"))"
            

            
            
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
        observeTyping()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { // 1
            cell.textView!.textColor = UIColor.whiteColor() // 2
        } else {
            cell.textView!.textColor = UIColor.blackColor() // 3
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        print("------message------")
        print(message)
        
        // Sent by me, skip
        if message.senderId == rootRef.authData.uid {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId == message.senderId {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.senderId == rootRef.authData.uid {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId == message.senderId {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    private func observeMessages() {
        // 1
        let messagesQuery = messageRef.queryLimitedToLast(25)
        // 2
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            // 3
            let id = snapshot.value["senderId"] as! String
            let text = snapshot.value["text"] as! String
            let senderDisplayName = snapshot.value["senderDisplayName"] as! String
            // 4
            self.addMessage(id, text: text, displayName: senderDisplayName)
            
            // 5
            self.finishReceivingMessage()
        }
    }
    
    private func observeTyping() {
        let typingIndicatorRef = rootRef.childByAppendingPath("typingIndicator")
        userIsTypingRef = typingIndicatorRef.childByAppendingPath(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
        usersTypingQuery.observeEventType(.Value) { (data: FDataSnapshot!) in
            
            // You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
        
    }
    
    func addMessage(id: String, text: String, displayName: String) {
        let message = JSQMessage(senderId: id, displayName: displayName, text: text)
        messages.append(message)
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let date = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let dateString = dateFormatter.stringFromDate(date)
        
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "text": text,
            "senderId": senderId,
            "senderDisplayName": senderDisplayName,
            "date": dateString
        ]
        itemRef.setValue(messageItem)
        print(messageItem["senderDisplayName"])
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        //5
        
        let parameters = ["conv_id":self.conversationKey,"type":"message"]
        Alamofire.request(.POST, "https://cryptic-river-41640.herokuapp.com/notifications",parameters: parameters)
        
        
        // 5
        finishSendingMessage()
        isTyping = false
    }
    
    private func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleRedColor())
        incomingBubbleImageView = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
}