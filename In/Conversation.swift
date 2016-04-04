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
    var messages = [String]()
    var participants = [String]()
    //String is a placeholder for the Message Object
    
    //MARK: Initializtion
    
    init(name:String, date:String, owner:String, conversationId:String, participants: [String]){
        //Messages temporarily removed from initialize parameters, put them back in later
        self.name = name
        self.date = date
        self.owner = owner
        self.conversationId = conversationId
        self.participants = participants
    }

}
