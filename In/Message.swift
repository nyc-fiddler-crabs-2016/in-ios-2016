//
//  Message.swift
//  In
//
//  Created by Apprentice on 4/3/16.
//  Copyright © 2016 Ryan F. Salerno. All rights reserved.
//

import UIKit

class Message{
    //MARK: Properties
    var conversationId:String
    var text:String
    var senderId:String
    var senderdisplayName:String

    //MARK: Initializtion
    
    init(text:String, senderId:String, senderdisplayName:String, conversationId:String){
        //Messages temporarily removed from initialize parameters, put them back in later
        self.text = text
        self.conversationId = conversationId
        self.senderId = senderId
        self.senderdisplayName = senderdisplayName
    }
    
}
