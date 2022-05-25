//
//  CommentViewController.swift
//  IOSApp
//
//  Created by berkay on 5/21/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var commentText: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    var postId: String = ""
    
    var commentArray = [Comment]()
    
    var name = [String]()
    var userPhotoUrl = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        takeCommentFromDatabase()
        nameCreator()
        findUrl()
    }
    

    
    func takeCommentFromDatabase(){
        let firestore = Firestore.firestore()
        let postRef = firestore.collection("Post").document(postId)
        postRef.collection("postComments")
            .order(by: "dateTime")
            .addSnapshotListener { (snapshot, error) in
            if error != nil {
                //hata oldu
            }
            else{
                self.commentArray.removeAll(keepingCapacity: false)
                for document in snapshot!.documents{
                    let userComment = document.get("comment") as! String
                    let username = document.get("username") as! String
                    let userPhoto = document.get("userPhoto") as! String
                    
                    let comment = Comment(comment: userComment, userId: Auth.auth().currentUser!.uid, userProfilePhotoUrl: userPhoto, userFullName: username)
                    self.commentArray.append(comment)
                }
                self.tableView.reloadData()
            }
        }
    }

    
    @IBAction func sendButtonTapped(_ sender: Any) {
        let firestore = Firestore.firestore()
        let postRef = firestore.collection("Post").document(postId)
        let commentRef = postRef.collection("postComments").document()
        let postComment = [
            "comment": commentText.text!,
            "username": self.name[0],
            "userPhoto": self.userPhotoUrl[0],
            "dateTime": FieldValue.serverTimestamp()
        ] as [String : Any]
        commentRef.setData(postComment) { (error) in
            if error != nil {
                //hata oldu
            }
            else{
                // işlemler başarılı
                self.commentText.text = ""
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        cell.commentLabel.text = commentArray[indexPath.row].comment
        cell.fullNameLabel.text = commentArray[indexPath.row].userFullName
        cell.profilePhoto.sd_setImage(with: URL(string: commentArray[indexPath.row].userProfilePhotoUrl))
        return cell
    }
    
    
    func nameCreator(){
        let docRef = ext()
        //fieldlara erişiyoruz
        docRef.getDocument { (document, error) in
            if let document = document, document.exists{
                if let first = document.get("firstName") as? String{
                    if let last = document.get("lastName") as? String{
                        //arraye isim append ediliyor
                        self.name.append(first.capitalizingFirstLetter()+" "+last.capitalizingFirstLetter())
                    }
                }
            }
        }
    }
    
    func findUrl(){
        let docRef = ext()
        //fieldlara erişiyoruz
        docRef.getDocument { (document, error) in
            if let document = document, document.exists{
                if let imageurl = document.get("photoUrl") as? String{
                    self.userPhotoUrl.append(imageurl)
                }
            }
        }
    }
    func ext() -> DocumentReference{
        let fireStore = Firestore.firestore()
       
        //özelleşmiş döküman id sini alıyor
        let docId = Auth.auth().currentUser!.uid
        //referansı tutuyor
        let docRef = fireStore.collection("Users").document(docId)
        return docRef
    }
}
