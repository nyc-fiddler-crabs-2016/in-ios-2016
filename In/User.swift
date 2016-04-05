//
//  User.swift
//  In
//
//  Created by Apprentice on 4/3/16.
//  Copyright © 2016 Ryan F. Salerno. All rights reserved.
//


import UIKit

class User {
    
    var id:String
    var name:String
    var email:String
    var password:String
    var deviceToken:String
    //MARK: Initializtion
    
    init(id:String, name:String, email:String, password:String, deviceToken:String
        ){
        //Messages temporarily removed from initialize parameters, put them back in later
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.deviceToken = deviceToken
    }
    
    
    
    
    
    
}