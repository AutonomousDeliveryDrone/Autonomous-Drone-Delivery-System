//
//  CompanySignUpViewController.swift
//  DeliveryDroneEcommerce
//
//  Created by Michael Peng on 4/9/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class CompanySignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var CeoName: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var uploadLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var companyImage: UIImageView!
    var imageURL: String = ""
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var isFood : Bool = false
    var isSupplies : Bool = false
    var isGadgets : Bool = false
    var isClothing : Bool = false
    var isStationaries : Bool = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        companyImage.layer.borderColor = UIColor.black.cgColor
//        companyImage.layer.borderWidth = 2
        
        signUpButton.layer.cornerRadius = 5
//        signUpButton.layer.shadowColor = UIColor.darkGray.cgColor
//        signUpButton.layer.shadowRadius = 5
//        signUpButton.layer.shadowOpacity = 0.5
        
//        backButton.layer.cornerRadius = signUpButton.frame.height / 3
//        backButton.layer.shadowColor = UIColor.black.cgColor
//        backButton.layer.shadowRadius = 2
//        backButton.layer.shadowOpacity = 0.5
        
        
        ref = Database.database().reference()
        
        
        companyImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        companyImage.isUserInteractionEnabled = true
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func handleSelectProfileImageView () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("selecting")
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            print("changing image")
            companyImage.image = selectedImage
        }
        companyImage.layer.borderWidth = 0
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func signUp(_ sender: Any) {
        if (Name.text?.isEmpty ?? true || CeoName.text?.isEmpty ?? true || location.text?.isEmpty ?? true || email.text?.isEmpty ?? true || password.text?.isEmpty ?? true) {
            print("THERE IS AN ERROR")
            let alert = UIAlertController(title: "Registration Error", message: "Please make sure you have completed filled out every textfield", preferredStyle: .alert)
            
            let OK = UIAlertAction(title: "OK", style: .default) { (alert) in
                return
            }
            
            alert.addAction(OK)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
                if (error == nil) {
                    self.storageRef = Storage.storage().reference().child("CompanyImages").child("\(self.Name.text as! String).png")
                    if let uploadData = self.companyImage.image?.pngData() {
                        print("storing image")
                        self.storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                            if (error != nil) {
                                
                                print(error)
                                return
                            }
                            self.storageRef.downloadURL(completion: { (url, error) in
                                if let err = error {
                                    print("-----------------")
                                    print("there was an error")
                                    print("----------------")
                                    print(err)
                                } else {
                                    self.imageURL = url!.absoluteString
                                    self.registerCompany(self.imageURL)
                                }
                            })
                            
                            
                        }
                    }
                    
                    self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Information").updateChildValues(["Status":"Company"])
                    self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Products").updateChildValues(["Index": 1])
//
//                    if (self.isFood) {
//                        self.ref.child("Storage").child("Food").child(Auth.auth().currentUser!.uid).updateChildValues(["Index" : 1])
//                    }
//                    if (self.isSupplies) {
//                        self.ref.child("Storage").child("Supplies").child(Auth.auth().currentUser!.uid).updateChildValues(["Index" : 1])
//                    }
//                    if (self.isGadgets) {
//                        self.ref.child("Storage").child("Gadgets").child(Auth.auth().currentUser!.uid).updateChildValues(["Index" : 1])
//                    }
//                    if (self.isClothing) {
//                        self.ref.child("Storage").child("Clothing").child(Auth.auth().currentUser!.uid).updateChildValues(["Index" : 1])
//                    }
//                    if (self.isStationaries) {
//                        self.ref.child("Storage").child("Stationaries").child(Auth.auth().currentUser!.uid).updateChildValues(["Index" : 1])
//                    }
//
                    
                    
                    

                    self.performSegue(withIdentifier: "companyToLogin", sender: self)
                } else {
                    //                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Registration Error", message: error?.localizedDescription as! String, preferredStyle: .alert)
                    
                    let OK = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                        self.password.text = ""
                    })
                    
                    alert.addAction(OK)
                    self.present(alert, animated: true, completion: nil)
                    print("--------------------------------")
                    print("Error: \(error?.localizedDescription)")
                    print("--------------------------------")
                }
            }
        }
    }
    
    func registerCompany(_ url : String) {
        self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Information").setValue(["Company" : self.Name.text!, "CEO" : self.CeoName.text!, "Address" : self.location.text!, "Email" : self.email.text!, "CompanyImage": url])
        
        self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Information").updateChildValues(["Status":"Company"])
        
    }
    

    
}
