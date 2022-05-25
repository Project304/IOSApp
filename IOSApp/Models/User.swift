//
//  User.swift
//  Project304IOSApp
//
//  Created by berkay on 5/17/22.
//

import Foundation

public class User {
    var userProfilePhotoUrl: String
    var name: String
    
    init(userProfilePhotoUrl:String, name:String) {
        self.userProfilePhotoUrl = userProfilePhotoUrl
        self.name = name
    }
}

