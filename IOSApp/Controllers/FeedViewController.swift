//
//  FeedViewController.swift
//  Project304IOSApp
//
//  Created by berkay on 4/26/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
//async image download library
import SDWebImage
    
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var tableView: UITableView!
    
    //feed elemanları için birer array
    var postArray = [Post]()
    var postId : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        takeDataFromFirebase()
    }
    
    
    func takeDataFromFirebase(){
        self.findFriends { (friend) in
            self.takeDataWithFriendEmail(friend: friend)
        }
    }
    
    func findFriends(completion : @escaping([String])-> ()){
        let firestoreDatabase = Firestore.firestore()
        //firestore altındaki collectionlardan erişim sağlamak istediğimizi seçiyoruz
        //collection altından istersek documnetlere ulaşılabilir fakat bize lazım olan tüm postlar
        let userRef = firestoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid) // mevcut kullanıcı
        
        userRef.getDocument { (document, error) in
            if let friends = document?.get("friend") as? [String]{
                completion(friends)
            }
        }
    }
            
    func takeDataWithFriendEmail(friend : [String]){
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("Post")
            .order(by: "dateTime", descending: true) //descent azalan şeklinde yeni atılan en üstte olacak
            .addSnapshotListener { (snapshot, error) in
            if error != nil{
                print(error?.localizedDescription ?? "Hata oluştu.")
            }
            else{
                //snapshot verilerin tutulduğu kısım onun için boş sorgulaması yapıyoruz
                if snapshot?.isEmpty != true && snapshot != nil {
                    //yeni bir upload yapıldığında gösterilen celler bir daha gösterilmesin diye bir arrayleri temizlememiz gerekiyor
                    self.postArray.removeAll(keepingCapacity: false)
                    for document in snapshot!.documents{
                        //görsel url si dataları çekmek için lazım stringe çeviriyoruz
                        if let user = document.get("userEmail") as? String{
                            if friend.contains(user) || user == Auth.auth().currentUser!.email! {
                                    //eğer arkadaşlar listesi bu post sahibini içeriyorsa işlemleri yap veya aynı zamanda post sahibi kendi postunu da görebilsin
                                    let imageUrl = document.get("imageUrl") as! String
                                    let comment = document.get("comment") as! String
                                    let fullName = document.get("fullName") as! String
                                    let profilePhoto = document.get("profilePhoto") as! String
                                    let id = document.get("postId") as! String
                                    let likes = document.get("likes") as! Int
                                    let likeGroup = document.get("likers") as! [String]
                                    let uid = document.get("userId") as! String
                                    
                                    let post = Post(postId: id, profilePhoto: profilePhoto, fullName: fullName, comment: comment, imageView: imageUrl, like: likes, likers: likeGroup,userId: uid)
                                    self.postArray.append(post)
                            }
                            
                        }
                    }
                    //yeni data geldi göster:
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //table view üzerinde post ile etkileşime girildiği zaman yorum sayfasına gönderecek
        //bunun için post idyi psot array içerisinden index pathe göre alıyoruz
        //segue yapacakken hedefteki classın post id sini de değiştiriyoruz
        self.postId = self.postArray[indexPath.row].postId ?? "nil"
        //
        performSegue(withIdentifier: "feedToCom", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedToCom"{
            let destVc = segue.destination as! CommentViewController
            destVc.postId = self.postId
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //yeniden kullanılabilir celler oluşturuyoruz ve bu celler bizim feed celle cast ediliyor
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        //profil fotoğrafını gösterecez
        cell.profilePhoto.sd_setImage(with: URL(string: postArray[indexPath.row].profilePhoto))
        cell.userInfoText.text = postArray[indexPath.row].fullName
        //görselleri url olarak tuttum bu urlden indirip göstermek için de "sdwebimage"
        //adlı kütüphaneyi kullandım"
        cell.postImageView.sd_setImage(with: URL(string: postArray[indexPath.row].imageView))
        cell.commentText.text = postArray[indexPath.row].comment
        cell.postId.text = postArray[indexPath.row].postId
        if postArray[indexPath.row].like == 0{
            cell.likeLabel.alpha = 0
            cell.likeDetail.alpha = 0
        }
        else{
            cell.likeLabel.alpha = 1
            cell.likeDetail.alpha = 1
        }
        cell.likeLabel.text = String(postArray[indexPath.row].like)
        cell.postComment.text = "daha fazla yorum görmek için tıklayınız ->"
        cell.likeDetail.text = "kere beğenildi"
        return cell
    }
    
    
}

