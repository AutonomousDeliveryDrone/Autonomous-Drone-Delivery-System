//
//  CompanyProductViewController.swift
//  DeliveryDroneEcommerce
//
//  Created by Michael Peng on 4/14/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class CompanyProductViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var company : String = ""
    var categoryType : String = ""
    var name : String = ""
    var price : Double = 0
    var desc : String = ""
    var link : String = ""
    var index : Int = 0
    var url : String = ""
    var amount : Int = 0
    var compID : String = ""
    var orderAmount: Int = 0
    
    var imageChanged : Bool = false
    var titleChanged : Bool = false
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDesc: UITextView!
    @IBOutlet weak var productLink: UILabel!
    @IBOutlet weak var restockAmount: UITextField!
    @IBOutlet weak var restockButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        priceTextField.keyboardType = UIKeyboardType.numberPad
        restockAmount.keyboardType = UIKeyboardType.numberPad
    
        ref = Database.database().reference()
        
        restockButton.layer.cornerRadius = 5
//        restockButton.layer.shadowColor = UIColor.systemBlue.cgColor
//        restockButton.layer.shadowRadius = 5
//        restockButton.layer.shadowOpacity = 0.7
        
        productName.text = name
        
        let roundedPrice = String(format: "%.2f", price)
        productPrice.text = "$\(roundedPrice)"
        productDesc.text = desc
        productLink.text = link
        
        productImage?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "Products"), options: .highPriority, progress: nil, completed: { (downloadImage, downloadException, cacheType, downloadURL) in
            
            if let downloadException = downloadException {
                print("Error downloading an image: \(downloadException.localizedDescription)")
            } else {
                print("Succesfully donwloaded image")
            }
        })
        
        productImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        productImage.isUserInteractionEnabled = false
        
    
    }
    
    @objc func handleSelectProfileImageView () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("selecting")
        imageChanged = true
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            print("changing image")
            productImage.image = selectedImage
        }
        productImage.layer.borderWidth = 0
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageChanged = false
        dismiss(animated: true, completion: nil)
    }

    @IBAction func add(_ sender: Any) {
        if let restockAmt = Int((self.restockAmount.text!)) {
            amount = amount + restockAmt
            ref.child("Storage").child(categoryType).child(compID).child(String(index)).updateChildValues(["Amount" : amount])
            ref.child(("UserInfo")).child(compID).child("Products").child(String(index)).updateChildValues(["Amount": amount])
            let alert = UIAlertController(title: "Success!", message: "Item has been restocked!", preferredStyle: .alert)
            
            let OK = UIAlertAction(title: "OK", style: .default) { (alert) in
                return
            }
            
            alert.addAction(OK)
            self.present(alert, animated: true, completion: nil)
        }
        restockAmount.text = ""
        
    }

    @IBAction func editPressed(_ sender: Any) {
        if (editButton.titleLabel?.text == "EDIT") {
            
            
            
            //Button Change
            editButton.setAttributedTitle(NSAttributedString(string: "DONE"), for: .normal)
            
            editButton.imageView?.isHidden = true
            
            //ProductImage
            productImage.isUserInteractionEnabled = true
            productImage.image = UIImage(named: "upload")
            
            //Title
            productName.isHidden = true
            nameTextField.isHidden = false
            nameTextField.text = productName.text
            
            //Price
            productPrice.isHidden = true
            priceTextField.isHidden = false
            priceTextField.text = String(price)
            
            //Description
            productDesc.isHidden = true
            descriptionTextField.isHidden = false
            descriptionTextField.text = productDesc.text
            
            //Link
            productLink.isHidden = true
            linkTextField.isHidden = false
            linkTextField.text = productLink.text
            
        } else {
            if (productName.text != nameTextField.text) {
                titleChanged = true
            }
            //Image + FirStorage
            productImage.isUserInteractionEnabled = false
            if (!imageChanged && !titleChanged) {
                print("NEITHER WERE CHANGED")
                productImage?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "Products"), options: .highPriority, progress: nil, completed: { (downloadImage, downloadException, cacheType, downloadURL) in
                    
                    if let downloadException = downloadException {
                        print("Error downloading an image: \(downloadException.localizedDescription)")
                    } else {
                        print("Succesfully donwloaded image")
                    }
                })
            } else if (!imageChanged && titleChanged){
                print("ONLY TITLE WAS CHANGED")
                productImage?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "Products"), options: .highPriority, progress: nil, completed: { (downloadImage, downloadException, cacheType, downloadURL) in
                    
                    if let downloadException = downloadException {
                        print("Error downloading an image: \(downloadException.localizedDescription)")
                    } else {
                        print("Succesfully donwloaded image")
                    }
                })
                let deleteImg = Storage.storage().reference().child("ProductImages").child(compID).child(productName.text! + ".png")
                storageRef = Storage.storage().reference().child("ProductImages").child(compID).child(nameTextField.text! + ".png")
                deleteImg.delete { (error) in
                    if let error = error {
                        print("Error occured with deleting image")
                    }
                    if let uploadData = self.productImage.image?.pngData() {
                        print("storing image")
                        self.storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                            if (error != nil) {
                                
                                print(error)
                                return
                            }
                            self.storageRef.downloadURL(completion: { (url, error) in
                                if let err = error {
                                    print("there was an error")
                                    print(err)
                                } else {
                                    self.url = url!.absoluteString
                                    self.uploadImageURL(self.url)
                                }
                            })
                            
                            
                        }
                    }
                }
            }
            else if (imageChanged && !titleChanged){
                print("ONLY IMAGE WAS CHANGED")
                storageRef = Storage.storage().reference().child("ProductImages").child(compID).child(productName.text! + ".png")
                let deleteImg = storageRef
                deleteImg!.delete { (error) in
                    if let error = error {
                        print("Error occured with deleting image")
                    }
                    if let uploadData = self.productImage.image?.pngData() {
                        print("storing image")
                        self.storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                            if (error != nil) {
                                print(error)
                                return
                            }
                            self.storageRef.downloadURL(completion: { (url, error) in
                                if let err = error {
                                    print("there was an error")
                                    print(err)
                                } else {
                                    self.url = url!.absoluteString
                                    self.uploadImageURL(self.url)
                                }
                            })
                            
                            
                        }
                    }
                }
                
            } else { //both were changed
                print("BOTH WERE CHANGED")
                print(productName.text!)
                print(nameTextField.text!)
                let deleteImg = Storage.storage().reference().child("ProductImages").child(compID).child(productName.text! + ".png")
                storageRef = Storage.storage().reference().child("ProductImages").child(compID).child(nameTextField.text! + ".png")
                deleteImg.delete { (error) in
                    if let error = error {
                        print("Error occured with deleting image")
                    }
                    if let uploadData = self.productImage.image?.pngData() {
                        print("storing image")
                        self.storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                            if (error != nil) {
                                print(error)
                                return
                            }
                            self.storageRef.downloadURL(completion: { (url, error) in
                                if let err = error {
                                    print("there was an error")
                                    print(err)
                                } else {
                                    self.url = url!.absoluteString
                                    self.uploadImageURL(self.url)
                                }
                            })
                            
                            
                        }
                    }
                }
            }
            imageChanged = false
            titleChanged = false
            
            //Title
            
            productName.text = nameTextField.text!
            productName.isHidden = false
            nameTextField.isHidden = true
            
            //Price
            
            productPrice.text = "$" + priceTextField.text!
            price = Double(priceTextField.text!)!
            productPrice.isHidden = false
            priceTextField.isHidden = true
            
            //Description
            productDesc.text = descriptionTextField.text!
            productDesc.isHidden = false
            descriptionTextField.isHidden = true
            
            //Link
            productLink.text = linkTextField.text!
            productLink.isHidden = false
            linkTextField.isHidden = true
            
            
            ref.child("Storage").child(categoryType).child(compID).child(String(index)).updateChildValues(["Product": nameTextField.text!, "Price" : Double(priceTextField.text!), "Description": descriptionTextField.text!, "Link": linkTextField.text!])
            ref.child("UserInfo").child(compID).child("Products").child(String(index)).updateChildValues(["Product": nameTextField.text!, "Price" : Double(priceTextField.text!), "Description": descriptionTextField.text!, "Link": linkTextField.text!])
            editButton.setAttributedTitle(NSAttributedString(string: "EDIT"), for: .normal)
            editButton.imageView?.isHidden = false
            
            
        }
        
        
        
    }
    
    func uploadImageURL(_ url : String) {
        ref.child("Storage").child(categoryType).child(compID).child(String(index)).updateChildValues(["ProductImage" : url])
        ref.child("UserInfo").child(compID).child("Products").child(String(index)).updateChildValues(["ProductImage" : url])
    }
    

}

