//
//  FriendCell.swift
//  IOSApp
//
//  Created by berkay on 5/22/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FriendCell: UITableViewCell {

    
    @IBOutlet weak var friendsEmailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func acceptTapped(_ sender: Any) {
        self.deleteInvite()
        self.addFriend()
        
    }
    
    @IBAction func ignoreTapped(_ sender: Any) {
        self.deleteInvite()
    }
    
    
    func deleteInvite(){
        let userRef = self.userReference()
        //invite fieldından siliyoruz arkadaş fieldına terfi edecek
        userRef.getDocument { (document, error) in
            if error == nil{
                if var invite = document?.get("invite") as? [String]{
                    if var inviteCount = document?.get("inviteCount") as? Int{
                        invite.remove(self.friendsEmailLabel.text!)
                        inviteCount -= 1
                        let inviteGroup = ["invite":invite,"inviteCount":inviteCount] as [String:Any]
                        userRef.setData(inviteGroup, merge: true)
                    }
                }
            }
        }
    }
    
    func addFriend(){
        let userRef = self.userReference()
        userRef.getDocument { (document, error) in
            if error == nil{
                if var friend = document?.get("friend") as? [String]{
                    if var friendCount = document?.get("friendCount") as? Int{
                        friend.append(self.friendsEmailLabel.text!)
                        friendCount += 1
                        let friendGroup = ["friend":friend, "friendCount":friendCount] as [String : Any]
                        userRef.setData(friendGroup, merge: true)
                    }
                }
            }
        }
        //kullanıcının kendisi için arkadaş ekledik sırada öbür kişi için arkadaş eklemek var
        let firestore = Firestore.firestore()
        let userMail = self.friendsEmailLabel.text!
        let friendRef = firestore.collection("Users").whereField("email", isEqualTo: userMail)
            friendRef.getDocuments { (snapshot, error) in
            if error == nil{
                //buradaki document fieldı olan friend'a mevcut kullanıcıyı ekleyecez
                for document in snapshot!.documents{
                    if var friend = document.get("friend") as? [String]{
                        if var friendCount = document.get("friendCount") as? Int{
                            //set data yapabilmek için user id yi alıyorum document parametresi olarak kullanacam
                            if let uid = document.get("userId") as? String{
                                friend.append(Auth.auth().currentUser!.email!)
                                friendCount += 1
                                let friendGroup = ["friend":friend,"friendCount":friendCount] as [String:Any]
                                firestore.collection("Users").document(uid).setData(friendGroup,merge: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func userReference() -> DocumentReference{
        let firestore = Firestore.firestore()
        let userId = Auth.auth().currentUser!.uid
        let userRef = firestore.collection("Users").document(userId)
        return userRef
    }
}
