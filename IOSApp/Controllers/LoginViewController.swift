//
//  LoginViewController.swift
//  Project304IOSApp
//
//  Created by berkay on 5/6/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements(){
        //başlangıç aşamasında error labelini gizliyoruz hata olması durumunda degeri 1 olacak
        errorLabel.alpha = 0
    }

    
    @IBAction func loginTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { (result, error) in
            if error != nil {
                self.errorLabel.text = "Lütfen tekrar deneyiniz!"
                self.errorLabel.alpha = 1
            }
            else{
                self.performSegue(withIdentifier: "toFeedVcFromLogin", sender: nil)
                }
            }
    }
    
    
    
    
    func errorMessage(errorTitle : String, errorMessage : String){
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}


