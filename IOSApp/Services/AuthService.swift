//
//  AuthService.swift
//  Project304IOSApp
//
//  Created by berkay on 5/7/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    
    static var firestore = Firestore.firestore()
    
    static func getUserId(userId: String) -> DocumentReference {
        //user table içerisindeki current userin olduğu yeri bulup hangi dökümandaysa
        //onun id değerini döndürecek
        return firestore.collection("Users").document(userId)
    }
    
}

