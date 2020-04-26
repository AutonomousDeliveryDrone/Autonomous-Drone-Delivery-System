//
//  UserOrderViewController.swift
//  DeliveryDroneEcommerce
//
//  Created by Michael Peng on 4/11/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase

class UserOrderViewController: UIViewController, UITextFieldDelegate {
    
    
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
    var previousOrderAmt: Int = 0 
    
    @IBOutlet weak var orderButton: UIButton!
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productDesc: UITextView!
    @IBOutlet weak var productLink: UILabel!
    @IBOutlet weak var orderAmount: UITextField!
    
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        orderAmount.keyboardType = UIKeyboardType.numberPad
        
        orderButton.layer.cornerRadius = 5
//        orderButton.layer.shadowColor = UIColor.systemBlue.cgColor
//        orderButton.layer.shadowRadius = 5
//        orderButton.layer.shadowOpacity = 0.7
        
        print("------------------")
        print(previousOrderAmt)
        print("------------------")
        
        orderAmount.delegate = self
        ref = Database.database().reference()
//        ref.child("Orders").setValue(["orderNum" : 1])
        
        productName.text = name
        let roundedPrice = String(format: "%.2f", price)
        productPrice.text = "$" + roundedPrice
        productDesc.text = desc
        productLink.text = link
        
        productImage?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "Products"), options: .highPriority, progress: nil, completed: { (downloadImage, downloadException, cacheType, downloadURL) in
            
            if let downloadException = downloadException {
                print("Error downloading an image: \(downloadException.localizedDescription)")
            } else {
                print("Succesfully donwloaded image")
            }
        })
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func orderPressed(_ sender: Any) {
        
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .long
        formatter.locale = Locale(identifier: "en_US")
        let time = formatter.string(from: date)
        
        
        
        let productStorage = Product(name: name, price: price, amount: amount, orderedAmount: previousOrderAmt, desc: desc, link: link, company: company, category: categoryType, companyID: compID, index: index, productImage:url)
        
        
      
        self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Information").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else {
                print("No Data!")
                return
            }
            
            let address = value["Address"] as! String
            let firstName = value["FirstName"] as! String
            let lastName = value["LastName"] as! String
            let fullName = firstName + " " + lastName
            

            
            self.ref.child("Orders").observeSingleEvent(of: .value, with: { (snapshot1) in
                guard let value0 = snapshot1.value as? NSDictionary else {
                    print("No Data!")
                    return
                }
                if let orderAmt = Int((self.orderAmount.text!)) {
                    if (orderAmt > self.amount) {
                        let alert = UIAlertController(title: "Purchasing Error", message: "Unfortunately, you are not able to purchase this amount", preferredStyle: .alert)
                        
                        let OK = UIAlertAction(title: "OK", style: .default) { (alert) in
                            return
                        }
                        
                        alert.addAction(OK)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    let place = value0["orderNum"] as! Int
                    let productList = ["Product":productStorage.name, "Price": productStorage.price, "Amount":productStorage.amount,"OrderedAmount": orderAmt, "Description" : productStorage.desc, "Link" : productStorage.link, "Company" : productStorage.company, "Index":productStorage.index, "Category": productStorage.category, "companyID" :productStorage.companyID, "ProductImage": productStorage.productImage,"CustomerName" : fullName, "Address" : address, "Place" : place, "Time" : time, "UserID" : Auth.auth().currentUser!.uid, "Status" : "Processing", "DistanceIndex" : 3 ] as [String : Any]
                    
                    
                    self.ref.child("Orders").child("Users").child(Auth.auth().currentUser!.uid).child(String(place)).updateChildValues(productList)
                    
                    
                    self.ref.child("Orders").child("Companies").child(self.compID).child(String(place)).updateChildValues(productList)
                    self.ref.child("Storage").child(self.categoryType).child(self.compID).child(String(self.index)).updateChildValues(["Amount" : self.amount - orderAmt, "OrderedAmount" : self.previousOrderAmt + orderAmt])
                    self.ref.child("UserInfo").child(self.compID).child("Products").child(String(self.index)).updateChildValues(["Amount" : self.amount - orderAmt, "OrderedAmount" : self.previousOrderAmt + orderAmt])
                    self.ref.child("Orders").updateChildValues(["orderNum" : place+1])
                    
                    self.performSegue(withIdentifier: "orderBack", sender: self)
                    
                } else {
                    print("Number was not entered")
                    return
                }
                
            })
        })
    }
    
    
}


