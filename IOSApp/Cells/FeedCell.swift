//
//  FeedCell.swift
//  Project304IOSApp
//
//  Created by berkay on 4/29/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FeedCell: UITableViewCell {
    
    
    @IBOutlet weak var postId: UILabel!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    
    @IBOutlet weak var userInfoText: UILabel!
    
    
    @IBOutlet weak var postImageView: UIImageView!
    
    
    @IBOutlet weak var commentText: UILabel!
    
    
    @IBOutlet weak var likeLabel: UILabel!
    
    
    @IBOutlet weak var likeDetail: UILabel!
    
    @IBOutlet weak var postComment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postId.alpha = 0 //post id daha user comment için lazım görünmez yapıyorum
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        let fireStoreDatabase = Firestore.firestore()
        let docRef = fireStoreDatabase.collection("Post").document(postId.text!)
        docRef.getDocument { (snapshot, error) in
            if error == nil{
                // hata yoksa
                
                if var likeGroup = snapshot?.get("likers") as? [String]{
                    let userid = Auth.auth().currentUser!.uid
                    // daha önce beğenilmemişse ilk atama özel yapılıyor
                    if likeGroup.count == 0{
                        if let likeCount = Int(self.likeLabel.text!) {
                            likeGroup.append(Auth.auth().currentUser!.uid) //beğenen kullanıcı
                            let likeStore = ["likes" : likeCount + 1,
                                             "likers": likeGroup] as [String : Any]
                            
                            fireStoreDatabase.collection("Post").document(self.postId.text!).setData(likeStore, merge: true)
                        }
                    }
                    else{
                        if likeGroup.contains(userid){
                            // beğeni kaldırılacak
                            if let likeCount = Int(self.likeLabel.text!) {
                                //remove element extension olarak yazdım
                                likeGroup.remove(Auth.auth().currentUser!.uid) //beğenmeyecek kullanıcı
                                let likeStore = ["likes" : likeCount - 1,
                                                "likers": likeGroup] as [String : Any]
                                fireStoreDatabase.collection("Post").document(self.postId.text!).setData(likeStore, merge: true)
                            }
                        }
                        else{
                            if let likeCount = Int(self.likeLabel.text!) {
                                likeGroup.append(Auth.auth().currentUser!.uid) //beğenen kullanıcı
                                let likeStore = ["likes" : likeCount + 1,
                                                     "likers": likeGroup] as [String : Any]
                                    
                                fireStoreDatabase.collection("Post").document(self.postId.text!).setData(likeStore, merge: true)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension Array where Element: Equatable {

    mutating func remove(_ element: Element) {
        
        _ = index(of: element).flatMap {
            self.remove(at: $0)
        }
    }
}

