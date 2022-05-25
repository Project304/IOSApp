//
//  ProfileFriendCell.swift
//  IOSApp
//
//  Created by berkay on 5/25/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfileFriendCell: UITableViewCell{

    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    @IBOutlet weak var userId: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func removeTapped(_ sender: Any) {
        // hem mevcut kullanıcıdan sil hem hedef kullanıcıdan mevcut kullanıcıyı sil
        self.removeCurrentUserAtTargetUser()
        self.removeFriendAtCurrentUser()
    }
    
    func removeFriendAtCurrentUser(){
        // elimizde hedefin id si var kaldırmak istediğimiz ise email adresi
        let firestore = Firestore.firestore()
        let userid = Auth.auth().currentUser!.uid
        let targetId = self.userId.text!
        firestore.collection("Users").document(userid)
        .getDocument { (document, error) in
            if var friend = document?.get("friend") as? [String]{
                if var friendCount = document?.get("friendCount") as? Int{
                    firestore.collection("Users").document(targetId).getDocument { (document, error) in
                        if let email = document?.get("email") as? String{
                            friend.remove(email)
                            friendCount -= 1
                            let friendGroup = ["friend":friend, "friendCount":friendCount] as [String:Any]
                            firestore.collection("Users").document(userid).setData(friendGroup,merge: true)
                        }
                    }
                }
            }
        }
    }
    
    func removeCurrentUserAtTargetUser(){
        let firestore = Firestore.firestore()
        let targetId = self.userId.text!
        firestore.collection("Users").document(targetId)
            .getDocument { (document, error) in
                if var friend = document?.get("friend") as? [String]{
                    if var friendCount = document?.get("friendCount") as? Int{
                        let email = Auth.auth().currentUser!.email!
                        friend.remove(email)
                        friendCount -= 1
                        let friendGroup = ["friend":friend, "friendCount":friendCount] as [String:Any]
                        firestore.collection("Users").document(targetId).setData(friendGroup,merge: true)
                    }
                }
            }
        
    }

}
