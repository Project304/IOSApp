//
//  ProfileViewController.swift
//  Project304IOSApp
//
//  Created by berkay on 5/17/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SDWebImage

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var postImageArray = [String]()
    var commentArray = [String]()
    var likes = [Int]()
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var friendCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        takeUserDataFromDatabase()
        takePostImageFromDatabaseWithUserUid()
    }
    
    
    func takeUserDataFromDatabase(){
        let fireStore = Firestore.firestore()
       
        //özelleşmiş döküman id sini alıyor
        let docId = Auth.auth().currentUser!.uid
        //referansı tutuyor
        let docRef = fireStore.collection("Users").document(docId)
        docRef.addSnapshotListener { (snapshot, error) in
            if error != nil{
                
            }
            else{
                if let imageUrl = snapshot?.get("photoUrl") as? String{
                    if let name = snapshot?.get("firstName") as? String{
                        if let surname = snapshot?.get("lastName") as? String{
                            if let friendCount = snapshot?.get("friendCount") as? Int{
                                self.profilePhoto.sd_setImage(with: URL(string: imageUrl))
                                self.nameLabel.text! = name.capitalizingFirstLetter()+" "+surname.capitalizingFirstLetter()
                                self.friendCountLabel.text! = "\(friendCount) arkadaşınız var."
                            }
                        }
                    }
                }
            }
        }
    }
    
    func takePostImageFromDatabaseWithUserUid(){
        let firestore = Firestore.firestore()
        firestore.collection("Post").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snapshot, error) in
            if error != nil{
                
            }
            else{
                for document in snapshot!.documents{
                    if let imageUrl = document.get("imageUrl") as? String{
                        if let comment = document.get("comment") as? String{
                            if let likes = document.get("likes") as? Int{
                                self.postImageArray.append(imageUrl)
                                self.commentArray.append(comment)
                                self.likes.append(likes)
                            }
                            
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postImageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        postCell.postImage.sd_setImage(with: URL(string: postImageArray[indexPath.row]))
        postCell.likesLabel.text = "\(self.likes[indexPath.row]) beğeni aldı"
        postCell.userComment.text! = commentArray[indexPath.row]
        return postCell
    }
    
}

