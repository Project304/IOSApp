//
//  ProfileFriendViewController.swift
//  IOSApp
//
//  Created by berkay on 5/25/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SDWebImage

class ProfileFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var photoUrl = [String]()
    var userArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
        takeUsersFromDatabase()
    }
    
    var friendArray = [String]()
    func takeUsersFromDatabase(){
        let firestore = Firestore.firestore()
        let userId = Auth.auth().currentUser!.uid
        let userCollectionRef = firestore.collection("Users")
        firestore.collection("Users").document(userId)
            .addSnapshotListener { (snapshot, error) in
                self.arrayCleaner()
                if let friends = snapshot?.get("friend") as? [String]{
                for friend in friends{
                    userCollectionRef.whereField("email", isEqualTo: friend)
                    .getDocuments { (snapshot, error) in
                            for document in snapshot!.documents{
                                let firstName = document.get("firstName") as! String
                                let lastName = document.get("lastName") as! String
                                let name = firstName.capitalizingFirstLetter()+" "+lastName.capitalizingFirstLetter()
                                self.nameArray.append(name)
                                let imgUrl = document.get("photoUrl") as! String
                                    self.photoUrl.append(imgUrl)
                                 let userId = document.get("userId") as! String
                                    self.userArray.append(userId)
                            }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    
    func arrayCleaner(){
        self.nameArray.removeAll(keepingCapacity: false)
        self.photoUrl.removeAll(keepingCapacity: false)
        self.userArray.removeAll(keepingCapacity: false)
    }
    
    func takeFriendEmail(completion: @escaping([String])->()){
        let userRef = self.userReference()
        userRef.getDocument { (document, error) in
            if error == nil{
                if let friends = document?.get("friend") as? [String]{
                    completion(friends)
                }
            }
        }
    }
    
    func userReference()->DocumentReference{
        let firestore = Firestore.firestore()
        let userId = Auth.auth().currentUser!.uid
        let userRef = firestore.collection("Users").document(userId)
        return userRef
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileFriendCell", for: indexPath) as! ProfileFriendCell
        cell.usernameLabel.text = nameArray[indexPath.row]
        cell.profilePhoto.sd_setImage(with: URL(string: self.photoUrl[indexPath.row]))
        cell.userId.text = self.userArray[indexPath.row]
        return cell
    }

}
