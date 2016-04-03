//
//  Conversation.swift
//  In
//
//  Created by Apprentice on 4/3/16.
//  Copyright © 2016 Ryan F. Salerno. All rights reserved.
//

import UIKit

class Conversation{
    //MARK: Properties
    var conversationId:String
    var name:String
    var date:String
    var owner:String
    var messages:Array
    
    //MARK: Initializtion
    
    init(name:String, date:String, owner:String, messages:Array, conversationId:String){
        self.name = name
        self.date = date
        self.owner = owner
        self.messages = messages
        self.conversationId = conversationId
    }

}
