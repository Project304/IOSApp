//
//  Comment.swift
//  Project304IOSApp
//
//  Created by berkay on 5/11/22.
//

import Foundation


class Comment {
    var comment : String
    var userId : String
    var userProfilePhotoUrl : String
    var userFullName : String
    
    init(comment:String, userId:String, userProfilePhotoUrl:String, userFullName:String) {
        self.comment = comment
        self.userId = userId
        self.userProfilePhotoUrl = userProfilePhotoUrl
        self.userFullName = userFullName

    }
}

