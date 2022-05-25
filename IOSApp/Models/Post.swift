//
//  File.swift
//  Project304IOSApp
//
//  Created by berkay on 5/1/22.
//

import Foundation

class Post {
    var postId : String?
    var fullName : String
    var profilePhoto : String //url tutulacak
    var comment : String
    var imageView : String  //url tutulacak
    var like : Int
    var likers : [String]
    var userId: String
    
    init(postId : String?,profilePhoto:String ,fullName : String, comment : String, imageView : String, like:Int, likers:[String], userId : String) {
        self.postId = postId
        self.profilePhoto = profilePhoto
        self.fullName = fullName
        self.comment = comment
        self.imageView = imageView
        self.like = like
        self.userId = userId
        self.likers = likers
    }
}

