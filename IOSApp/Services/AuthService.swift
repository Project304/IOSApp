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
        //user table içerisindeki current userin id'sini kullanarak dökümanın referans değerini döndürdük
        return firestore.collection("Users").document(userId)
    }
    
}

