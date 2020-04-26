//
//  CompanyHomeViewController.swift
//  DeliveryDroneEcommerce
//
//  Created by Michael Peng on 4/9/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase

class CompanyHomeViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    
    
    var productList: [Product] = [Product]()
    var searchedProduct = [Product]()
    
    @IBOutlet weak var productSearch: UISearchBar!
    var company : String = ""
    var categoryType : String = ""
    var name1 : String = ""
    var price1 : Double = 0
    var desc1 : String = ""
    var link1 : String = ""
    var index1 : Int = 0
    var imageURL : String = ""
    var amount1 : Int = 0
    var compID : String  = ""
    var orderAmount1 : Int = 0
    
    var rowPressed: Int = 0
    var searching = false
    
    let random = 3.5
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("VIEWDIDAPPEAR")
        if (categoryType != "") {
            ref.child("Storage").child(categoryType).child(compID).child(String(index1)).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let value = snapshot.value as? NSDictionary else {
                        print("could not collect data")
                        return
                    }
                self.productList[self.rowPressed].name = value["Product"] as! String
                self.productList[self.rowPressed].price = value["Price"] as! Double
                self.productList[self.rowPressed].desc = value["Description"] as! String
                self.productList[self.rowPressed].link = value["Link"] as! String
                self.productList[self.rowPressed].amount = value["Amount"] as! Int
                
                self.tableView.reloadData()
            })
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("---------------")
        print(String(format: "%.3f", random))
        print("--------------")
        print("VIEWDIDLOAD")
        
        tableView.dataSource = self
        tableView.delegate = self
        productSearch.delegate = self
        
        tableView.register(UINib(nibName: "ProductCellTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell2" )
        ref = Database.database().reference()
        retrieveData()
    }
    
    
    func retrieveData() {
        print(Auth.auth().currentUser!.uid)
        self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Products").observeSingleEvent(of: .value, with: { (snapshot) in
            //        print("retrieve data: " + String(Data.childrenCount))
            //
            for children in snapshot.children.allObjects as! [DataSnapshot] {
                //                print(snapshot)
                guard let value = children.value as? NSDictionary else {
                    print("could not collect label data")
                    return
                }
                
                let amount = value["Amount"] as! Int
                let company = value["Company"] as! String
                let desc = value["Description"] as! String
                let index = value["Index"] as! Int
                let link = value["Link"] as! String
                let name = value["Product"] as! String
                let price = value["Price"] as! Double
                let category = value["Category"] as! String
                let compID = value["companyID"] as! String
                let image = value["ProductImage"] as! String
                let orderAmount = value["OrderedAmount"] as! Int
                
                
                let productStorage = Product(name: name, price: price, amount: amount, orderedAmount: orderAmount, desc: desc, link: link, company: company, category: category, companyID: compID, index: index, productImage: image)
                
                self.productList.append(productStorage)
                self.tableView.reloadData()
            }
        }) { (error) in
            print("error:\(error.localizedDescription)")
        }
    }
    
    
    
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "companyBack", sender: self)
            
        }catch let signOutError as NSError {
            print("Logout Error")
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProdView") {
            let secondVC = segue.destination as! CompanyProductViewController
            secondVC.company = company
            secondVC.categoryType = categoryType
            secondVC.name = name1
            secondVC.price = price1
            secondVC.desc = desc1
            secondVC.link = link1
            secondVC.index = index1
            secondVC.url = imageURL
            secondVC.amount = amount1
            secondVC.compID = compID
            secondVC.orderAmount = orderAmount1
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("hi")
        searchedProduct = productList.filter({$0.name.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}



extension CompanyHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            print("hi!")
               return searchedProduct.count
           } else {
               return productList.count
           }
        
        //might need to change later if we decide to add more categories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell2", for: indexPath) as! ProductCellTableViewCell
        
        var current : Product = productList[indexPath.row]
        if searching {
            current = searchedProduct[indexPath.row]
        } else {
            current = productList[indexPath.row]
        }
        cell.title.text = current.name
        
        let roundedPrice = String(format: "%.2f", current.price)
        cell.price.text = "$\(roundedPrice)"
        cell.category.text = current.category
        cell.amountLeft.text = "Left: \(String(current.amount))"
        cell.orderedAmt.text = "Ordered: \(String(current.orderedAmount))"
        
        let imageURL = current.productImage
        cell.prodImage?.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "Products"), options: .highPriority, progress: nil, completed: { (downloadImage, downloadException, cacheType, downloadURL) in
            
            if let downloadException = downloadException {
                print("Error downloading an image: \(downloadException.localizedDescription)")
            } else {
                print("Succesfully donwloaded image")
            }
        })
        
        
        
        //        cell.categoryLabel.text = categories[indexPath.row].categoryType
        //        cell.categoryImage.image = images[indexPath.row]
        return cell
    }
}

extension CompanyHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        rowPressed = indexPath.row
        if (searching) {
        name1 = searchedProduct[indexPath.row].name
        categoryType = searchedProduct[indexPath.row].category
        price1 = searchedProduct[indexPath.row].price
        desc1 = searchedProduct[indexPath.row].desc
        link1 = searchedProduct[indexPath.row].link
        index1 = searchedProduct[indexPath.row].index
        imageURL = searchedProduct[indexPath.row].productImage
        amount1 = searchedProduct[indexPath.row].amount
        compID = searchedProduct[indexPath.row].companyID
        orderAmount1 = searchedProduct[indexPath.row].orderedAmount
        performSegue(withIdentifier: "toProdView", sender: self)
        print(indexPath.row)
        }
        else {
            name1 = productList[indexPath.row].name
            categoryType = productList[indexPath.row].category
            price1 = productList[indexPath.row].price
            desc1 = productList[indexPath.row].desc
            link1 = productList[indexPath.row].link
            index1 = productList[indexPath.row].index
            imageURL = productList[indexPath.row].productImage
            amount1 = productList[indexPath.row].amount
            compID = productList[indexPath.row].companyID
            orderAmount1 = productList[indexPath.row].orderedAmount
            performSegue(withIdentifier: "toProdView", sender: self)
        }
    }
}

//extension CompanyHomeViewController: UISearchBarDelegate {
//
//
//
//}

