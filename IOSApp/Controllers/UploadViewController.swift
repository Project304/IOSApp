//
//  UploadViewController.swift
//  Project304IOSApp
//
//  Created by berkay on 4/26/22.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class UploadViewController: UIViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate{
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    var name = [String]()
    
    var photoUrl = [String]()
    var likers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //kullanıcının 'görsel yüklemek için tıkla' adlı bölgeyle etkileşime girebileceği söylendi
        imageView.isUserInteractionEnabled = true
        
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(takeImage))
        
        imageView.addGestureRecognizer(gestureRecognizer)
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
    
    //bu fonksiyon resim seçildikten sonra ne olacağına karar verdiğimiz bir fonksiyon
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //gelen image ui image type ı mı taşıyor
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func nameCreator(){
        let docRef = ext()
        //fieldlara erişiyoruz
        docRef.getDocument { (document, error) in
            if let document = document, document.exists{
                if let first = document.get("firstName") as? String{
                    if let last = document.get("lastName") as? String{
                        //arraye isim append ediliyor
                        print(first)
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
                    self.photoUrl.append(imageurl)
                }
            }
        }
    }
    
    func ext() -> DocumentReference{
        let fireStore = Firestore.firestore()
       
        //özelleşmiş döküman id sini alıyor
        let docId = self.findDocumentId()
        //referansı tutuyor
        let docRef = fireStore.collection("Users").document(docId!)
        return docRef
    }
    
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        let storage = Storage.storage()
        //bu referans firebase içerisinde ana storage klasör uzantısını tutuyor
        //alt klasörlerde işlem yapılacağı için böyle bir yöntem tercih ettim
        let storageReference = storage.reference()
        //referansı ve child fonksiyonu kullanarak parametresini oluşturmak istediğimiz
        //argümanı veriyoruz ve reference altında bir klasör elde ediyoruz bu devam edebilir sürekli
        let mediaFolder = storageReference.child("Media")//.child("Images")
        self.findUrl()
        self.nameCreator()
        
        //imageler byte olarak saklandığı için dosya dönüştürmesi yapmamız lazım (view to byte..)
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){ //sıkıştırma kalitesi 0-1 arası değer alır
            
            //universal unique id
            let uuid = UUID().uuidString
            //imageler veri tabanına kayıt edilirken uniq id leri ile kayıt olacak
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { (storagemetadata, error) in
                if error != nil{
                    //REFACTOR EDİLECEK
                    self.errorMessage(errorTitle: "Hata!", errorMessage: error?.localizedDescription ?? "Üzgünüz, Bizden kaynaklanan bir hata oluştu.")
                }
                else{
                    //amacımız imagenin veri tabanındaki urlsini almak
                    imageReference.downloadURL { [self] (url, error) in
                        if error == nil{
                            //url stringe çevriliyor
                            let imageUrl = url?.absoluteString
                            //bu yapıyla opsiyonel string olma durumundan çıkardık
                            //mecburen string olduğununda kullanacaz
                            if let imageUrl = imageUrl{
                                let firestore = Firestore.firestore()
                                let postId = UUID().uuidString
                                let firestorePost = [
                                    "postId" : postId,
                                    "profilePhoto": self.photoUrl[0],
                                    "imageUrl" : imageUrl,
                                    "comment" : self.textField.text!,
                                    "fullName" : self.name[0], //arrayde tek isim var
                                    "dateTime" : FieldValue.serverTimestamp(),
                                    "likes": 0,
                                    "likers": self.likers,
                                    "userId" : Auth.auth().currentUser!.uid,
                                    "userEmail": Auth.auth().currentUser!.email!
                                ] as [String : Any] //farklı formatlar olduğu için tanımlama böyle
                                
                                let postRef = firestore.collection("Post").document(postId)
                                postRef.setData(firestorePost) { (error) in
                                    if error != nil{
                                        self.errorMessage(errorTitle: "Hata!", errorMessage: error?.localizedDescription ?? "Üzgünüz, bizden kaynaklı bir hata oluştu. Lütfen tekrar deneyiniz.")
                                    }
                                    else{
                                        //yükleme esnasında bir hata olmadıysa
                                        //yükleme başarılıdır her şeyi eski haline getir
                                        self.textField.text = ""
                                        self.imageView.image = UIImage(named: "phone")
                                        self.name.removeAll(keepingCapacity: false) //array temizle
                                        self.photoUrl.removeAll(keepingCapacity: false)
                                        self.tabBarController?.selectedIndex = 0 //feed e döndürür
                                    }
                                }
                                postRef.collection("postComments").document()
                                                        
                                
                            }
                        }
                    }
                }
            }//metadata fotoya ait özellikleri tutar
        }
    }
    
    
    func findDocumentId() -> String? {
        //document id ve user id şu an aynı degere sahip
        //documentReference  : 0x600001b8c1b0 gibi bir değer döndürüyor
        let docId = Auth.auth().currentUser?.uid
        
        return docId
    }

    
    //current userın olduğu document id yi bulmak amaç
    
    func errorMessage(errorTitle : String, errorMessage : String){
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

