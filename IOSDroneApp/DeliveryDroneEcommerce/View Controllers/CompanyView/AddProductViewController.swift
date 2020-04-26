//
//  AddProductViewController.swift
//  DeliveryDroneEcommerce
//
//  Created by Michael Peng on 4/9/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import PMSuperButton
import SVProgressHUD

class CellClass: UITableViewCell {
    
}
class AddProductViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var productTitle: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var productLink: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var productImage: UIImageView!
    
    var imageURL: String = ""
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    let transparentView = UIView()
    let tableView = UITableView()
    
    var selectedButton = UIButton()
    
    var dataSource = [String]()
    
//    @IBOutlet weak var plusButton: PMSuperButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        price.keyboardType = UIKeyboardType.decimalPad
        amount.keyboardType = UIKeyboardType.numberPad
        
        
        addButton.layer.cornerRadius = 15
//        addButton.layer.shadowColor = UIColor.black.cgColor
//        addButton.layer.shadowRadius = 15
//        addButton.layer.shadowOpacity = 0.7
        
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        productImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        productImage.isUserInteractionEnabled = true
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
            productImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Add(_ sender: Any) {
//        SVProgressHUD.show(withStatus: "Storing Product")
        let categoryText = categoryButton.titleLabel?.text as! String
        if (productTitle.text?.isEmpty ?? true || price.text?.isEmpty ?? true || amount.text?.isEmpty ?? true || desc.text?.isEmpty ?? true || productLink.text?.isEmpty ?? true || categoryText == "Category") {
            
            print("THERE IS AN ERROR")
            let alert = UIAlertController(title: "Error Detected", message: "Please make sure you have completed every field", preferredStyle: .alert)
            
            let OK = UIAlertAction(title: "OK", style: .default) { (alert) in
                return
            }
            
            alert.addAction(OK)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            //            ref.child("Storage").child(categoryText).setValue(["Index" : 1])
            let priceInt: Double? = Double(price.text!)
            let amountInt: Int? = Int(amount.text!)
            
            self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Information").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let value0 = snapshot.value as? NSDictionary else {
                    print("No Data!")
                    return
                }
                let name = value0["Company"] as! String
                
                

                
                self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Products").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    
                    guard let value = snapshot.value as? NSDictionary else {
                        print("No Data!!!")
                        return
                    }
                    let index = value["Index"] as! Int
                    print("Index:"+String(index))
                    
                    self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Products").updateChildValues(["Index" : index+1])
                    
                    self.storageRef = Storage.storage().reference().child("ProductImages").child(Auth.auth().currentUser!.uid).child("\(self.productTitle.text as! String).png")
                    if let uploadData = self.productImage.image?.pngData() {
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
                                    self.addProduct(self.imageURL, priceInt!, amountInt!, name, categoryText, index)
                                }
                            })
                            
                            
                        }
                    }
                    
                    
                    
                    
                }) { (error) in
                    print("error:\(error.localizedDescription)")
                }
                
            }) { (error) in
                print("error:\(error.localizedDescription)")
            }
            
            
        }
//        SVProgressHUD.dismiss()
    }
    
    func addProduct(_ url : String, _ priceInt : Double, _ amountInt : Int, _ name : String, _ categoryText : String, _ index : Int) {
        var productList = ["Product":self.productTitle.text, "Price": priceInt, "Amount":amountInt, "OrderedAmount" : 0, "Description" : self.desc.text, "Link" : self.productLink.text, "Company" : name, "Index":index, "Category": categoryText, "companyID" :Auth.auth().currentUser!.uid, "ProductImage": url] as [String : Any]
       self.ref.child("Storage").child(categoryText).child(Auth.auth().currentUser!.uid).child(String(index)).setValue(productList)
       
       self.ref.child("Storage").child(categoryText).child(Auth.auth().currentUser!.uid).updateChildValues(["companyID" :Auth.auth().currentUser!.uid ])
           
       
       self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Products").child(String(index)).updateChildValues(productList)
//        SVProgressHUD.dismiss()
        self.performSegue(withIdentifier: "backToCompanyHome", sender: self)
       
    }
    @IBAction func categoryChoose(_ sender: Any) {
        dataSource = ["Food", "Supplies", "Gadgets", "Clothing", "Stationaries"]
        selectedButton = categoryButton
        addTransparentView(frames: categoryButton.frame)
    }
    
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * 50))
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
}


extension AddProductViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
        removeTransparentView()
    }
}

