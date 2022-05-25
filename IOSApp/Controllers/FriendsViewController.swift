//
//  FriendsViewController.swift
//  IOSApp
//
//  Created by berkay on 5/22/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var sendFriendsMailText: UITextField!
    
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var errorLabel: UILabel!
    var uidArray = [String]()
    var InviteArray = [String]()
    
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        errorLabel.alpha = 0
        refresh.addTarget(self, action: #selector(takeFriendsInviteFromDatabase), for: .valueChanged)
        tableView.addSubview(refresh)
        takeFriendsInviteFromDatabase()
    }
    
    
    @objc func takeFriendsInviteFromDatabase(){
        let firestore = Firestore.firestore()
        let userRef = firestore.collection("Users").document(Auth.auth().currentUser!.uid)
        userRef.addSnapshotListener { (document, error) in
            if error != nil{
                
            }
            else{
                self.InviteArray.removeAll(keepingCapacity: false)
                if let invites = document?.get("invite") as? [String]{
                    if let inviteCount = document?.get("inviteCount") as? Int{
                        for invite in invites{
                            self.InviteArray.append(invite)
                        }
                        self.countLabel.text! = "\(inviteCount) istek var."
                    }
                }
                self.refresh.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return InviteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        cell.friendsEmailLabel.text! = self.InviteArray[indexPath.row]
        return cell
    }
    

    @IBAction func sendTapped(_ sender: Any) {
        self.findUid()
    }
    
    
    func addFriendList(userId : String){
        let firestore = Firestore.firestore()
        let userRef = firestore.collection("Users").document(userId)
        //gelen arkadaş isteklerine eklemek lazım
        userRef.getDocument { (snapshot, error) in
            if error == nil{
                let friend = snapshot?.get("friend") as! [String]
                if var invite = snapshot?.get("invite") as? [String]{
                    let funcError = self.error(friend: friend, invite: invite)
                    
                    if funcError == nil{
                        if var inviteCount = snapshot?.get("inviteCount") as? Int{
                        invite.append(Auth.auth().currentUser!.email!)
                        inviteCount += 1
                        let inviteArray = ["invite":invite,
                                           "inviteCount": inviteCount] as [String:Any]
                        
                        userRef.setData(inviteArray, merge: true) { (error) in
                            if error != nil{
                                //hata var
                            }
                            else{
                                //hata yok eski haline çevir
                                self.sendFriendsMailText.text = ""
                                self.errorLabel.textColor = UIColor.green
                                self.errorLabel.text = "Başarılı şekilde gönderildi."
                                self.errorLabel.alpha = 1
                                invite.removeAll(keepingCapacity: false)
                                }
                            }
                        
                        }
                    }
                }
            }
        }
    }
    
    func error(friend:[String], invite: [String])-> Any?{
        let userMail = Auth.auth().currentUser!.email!
        
        if invite.contains(userMail){
            self.errorLabel.textColor = UIColor.red
            self.errorLabel.text = "Daha önce istek gönderildi."
            self.errorLabel.alpha = 1
            return -1
        }
        
        if  friend.contains(userMail){
            self.errorLabel.textColor = UIColor.red
            self.errorLabel.text = "Zaten arkadaşsınız."
            self.errorLabel.alpha = 1
            return -1
        }
        
        if userMail == self.sendFriendsMailText.text!{
            self.errorLabel.textColor = UIColor.red
            self.errorLabel.text = "Kendinize istek gönderemezsiniz."
            self.errorLabel.alpha = 1
            return -1
        }
        
        return nil
    }
    
    
    func findUid(){
        let firestore = Firestore.firestore()
        //firestore user içerisindeki email olarak girilen kullanıcıyı bulduk
        let email = sendFriendsMailText.text!
        firestore.collection("Users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            if error != nil{
                
            }
            else{
                for document in snapshot!.documents{
                    if let userid = document.get("userId") as? String{
                        self.addFriendList(userId: userid)
                    }
                }
            }
        }
    }
}
