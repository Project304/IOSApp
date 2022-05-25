//
//  SignUpViewController.swift
//  Project304IOSApp
//
//  Created by berkay on 5/6/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController,UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    
    
    @IBOutlet weak var profilePhotoSign: UIImageView!
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var urlArray = [String]()
    
    let Invite = [String]()
    
    let Friend = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElement()
        //kullanıcı image view ile etkileşime girebilir artık
        profilePhotoSign.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(takeImage))
        
        profilePhotoSign.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func takeImage(){
        //burda pick yapabilmek için classa ekstradan ui lar implement ediyoruz
        //pickten kasıt fotoğrafın seçimi için
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        //ACCESS GRAND LAZIM
        //fotonun hangi kaynaktan geleceğiniz seçiyoruz
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //gelen image ui image type ı mı taşıyor
        profilePhotoSign.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setUpElement(){
        errorLabel.alpha = 0
    }
    
    
    @IBAction func signUpTapped(_ sender: Any) {
        //field return deperine göre işlem yapıyoruz
        let error = checkTextField()
    
        if error == nil {
            //kullanıcıyı oluşturuyoruz
            
            Auth.auth().createUser(withEmail: emailTextField.text!.trimmingCharacters(in:   .whitespacesAndNewlines), password: passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { (authdataresult, error) in
                if error == nil{
                    // kullanıcı başarılı bir şekilde oluşturuldu "db" de userı oluşturdum burada
                    //let db = Firestore.firestore()
                    // photo urlsi
                    let storage = Storage.storage()
                    let storageReference = storage.reference()
                    let photoFolder = storageReference.child("Photo")
                    if let data = self.profilePhotoSign.image?.jpegData(compressionQuality: 0.5){
                        let key = Auth.auth().currentUser!.uid // key ataması
                        let imageReference = photoFolder.child("\(key).jpg")
                        imageReference.putData(data, metadata: nil) { (meta, error) in
                            if error != nil{
                                self.errorLabel.text = "Fotoğraf kaydedilemedi. Lütfen tekrar deneyiniz."
                                self.errorLabel.alpha = 1
                            }
                            imageReference.downloadURL { (url, error) in
                                if error == nil {
                                    let imageUrl = url?.absoluteString
                                    if let imageUrl = imageUrl{
                                        let rest = AuthService.getUserId(userId: authdataresult!.user.uid)
                                        let data = ["firstName":self.firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), "lastName":self.lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), "photoUrl": imageUrl,
                                            "userId": authdataresult!.user.uid,
                                            "email": authdataresult!.user.email ?? "default@mail.com",
                                            "invite": self.Invite,
                                            "inviteCount": 0,
                                            "friend": self.Friend,
                                            "friendCount":0] as [String : Any]
                                        
                                        rest.setData(data){ (error) in
                                            if error != nil {
                                                self.errorMessage(titleInput: "Hata", messageInput: "Kullanıcı başarılı şekilde kaydedilemedi. Lütfen tekrar deneyiniz.")
                                            }
                                            else{
                                                //tüm işlemler başarılı oldu anasayfaya segue yapıyorum
                                                self.performSegue(withIdentifier: "toFeedVcFromSignUp", sender: nil)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
                else{
                    //bir hata oluştu
                    self.errorMessage(titleInput: "Hata!", messageInput: "Üzgünüz, kaydınız başarısız oldu. Lütfen tekrar deneyiniz.")
                }
            }
        }
    }
    
    func checkTextField() -> Any? {
        //tüm text fieldlar dolduruldu mu kontrolü yapılıyor
        if  firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        {
            errorLabel.text = "Lütfen isim alanını doldurunuz!"
            errorLabel.alpha = 1
        }
        else if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        {
            errorLabel.text = "Lütfen soy isim alanını doldurunuz!"
            errorLabel.alpha = 1
        }
        else if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        {
            errorLabel.text = "Lütfen email alanını doldurunuz!"
            errorLabel.alpha = 1
        }
        else if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
                    lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            errorLabel.text = "Lütfen bir şifre belirleyiniz!"
            errorLabel.alpha = 1
        }
        return nil
    }
    
    func errorMessage(titleInput : String, messageInput : String){
        //alert tanımlanıyor
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        //ok button tanımlanıyor
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        performSegue(withIdentifier: "signUpToMain", sender: nil)
    }
    
    
}

