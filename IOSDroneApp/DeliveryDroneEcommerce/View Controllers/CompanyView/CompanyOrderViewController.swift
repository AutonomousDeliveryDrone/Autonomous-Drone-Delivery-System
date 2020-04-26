//
//  CompanyOrderViewController.swift
//  DeliveryDroneEcommerce
//
//  Created by Gavin Wong on 4/13/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class CompanyOrderViewController: UIViewController {
    
    var orders : [CompanyOrder] = []
    @IBOutlet weak var tableView: UITableView!
    
    var company : String = ""
      var time : String = ""
      var name : String = ""
      var address : String = ""
      var price : Double = 0
      var dist : Int = 0
    
    
    var status : String = ""
    var companyID : String = ""
    var userID : String = ""
    var place : Int = 0
    var orderAmount: Int = 0
    
    var rowPressed : Int = -1
    
    var ref: DatabaseReference!
    
    override func viewDidAppear(_ animated: Bool) {
        print("VIEWDIDAPPEAR")
        if (rowPressed != -1) {
            ref.child("Orders").child("Companies").child(companyID).child(String(place)).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let value = snapshot.value as? NSDictionary else {
                        print("could not collect data")
                        return
                    }
                self.orders[self.rowPressed].status = value["Status"] as! String
                
                self.tableView.reloadData()
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ref = Database.database().reference()
        retrieveOrders()
        
        tableView.reloadData()
        
        tableView.register(UINib(nibName: "CompanyOrderCell", bundle: nil), forCellReuseIdentifier: "CompanyOrderCell")
        
        // Do any additional setup after loading the view.
    }
    
    func retrieveOrders () {
        orders = []
        ref.child("Orders").child("Companies").child(Auth.auth().currentUser!.uid).queryOrdered(byChild: "Price").observeSingleEvent(of: .value) { (snapshot) in
            //gettin the companyID
            //            let post = Post.init(key: snapshot.key, date: snapshot.value!["date"] as! String, postedBy: snapshot.value!["postedBy"] as! String, status: snapshot.value!["status"] as! String)
            
            //            let post = Post.init(key: snapshot.key, date: snapshot.value!["date"] as! String, postedBy: snapshot.value!["postedBy"] as! String, status: snapshot.value!["status"] as! String)
            
            
            print("loop")
            for children in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = children.value as? NSDictionary else {
                    print("could not collect data")
                    return
                }
                
                let companyID = value["companyID"] as! String
                print("----------------")
                print(companyID)
                print("----------------")
                let price = value["Price"] as! Double
                let product = value["Product"] as! String
                let place = value["Place"] as! Int
                let desc = value["Description"] as! String
                let address = value["Address"] as! String
                let name = value["CustomerName"] as! String
                let time = value["Time"] as! String
                let userID = value["UserID"] as! String
                let status = value["Status"] as! String
                let compID = value["companyID"] as! String
                let dist = value["DistanceIndex"] as! Int
                let orderAmt = value["OrderedAmount"] as! Int
                
                
                //making the company cells
                self.ref.child("UserInfo").child(companyID).child("Information").observeSingleEvent(of: .value) { (snap) in
                    guard let val = snap.value as? NSDictionary else {
                        print("could not collect data")
                        return
                    }
                    let Name = val["Company"] as! String
                    let Image = val["CompanyImage"] as! String
                    
                    let order = CompanyOrder(productName: product, price: price, customerName: name, address: address, time: time, place: place, status: status, userID: userID, companyID: compID, distIndex: dist, orderAmount: orderAmt)
                    self.orders.append(order)
                    self.orders.sort(by: {$0.place < $1.place})
                    print("Prduct:" + product)
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCompProgress") {
            let secondVC = segue.destination as! CompanyProgressViewController
            secondVC.comp = company
            secondVC.time = time
            secondVC.name = name
            secondVC.price = price
            secondVC.address = address
            secondVC.distIndex = dist
            secondVC.userID = userID
            secondVC.companyID = companyID
            secondVC.status = status
            secondVC.place = place
            secondVC.orderAmount = orderAmount

        }
    }
    
    
    
}

extension CompanyOrderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyOrderCell", for: indexPath) as! CompanyOrderCell
        //        cell.productDescription.text = orders[indexPath.row].description
        cell.productName.text = orders[indexPath.row].productName
        cell.customerAddress.text = "Deliver to: \(orders[indexPath.row].address)"
        cell.timePurchased.text = "Time purchased: \(orders[indexPath.row].time)"
        cell.customerName.text = "Customer: \(orders[indexPath.row].customerName)"
        let roundedPrice = String(format: "%.2f", orders[indexPath.row].price * Double(orders[indexPath.row].orderAmount))
        cell.price.text = "$\(roundedPrice)"
        cell.statusLabel.text = "Status:\(orders[indexPath.row].status)"
        return cell
    }
    
    
}

extension CompanyOrderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowPressed = indexPath.row
//        if orders[indexPath.row].status == "Processing" {
//            let alert = UIAlertController(title: "Change Status", message: "Change Status of Order", preferredStyle: .alert)
//
//            let change = UIAlertAction(title: "In Transit", style: .default) { (alert) in
//                self.ref.child("Orders").child("Users").child(self.orders[indexPath.row].userID).child(String(self.orders[indexPath.row].place)).updateChildValues(["Status" : "In Transit"])
//                self.ref.child("Orders").child("Companies").child(self.orders[indexPath.row].companyID).child(String(self.orders[indexPath.row].place)).updateChildValues(["Status" : "In Transit"])
//                self.retrieveOrders()
//                self.tableView.reloadData()
//
//            }
//            let cancel = UIAlertAction(title: "Cancel", style: .default) { (alert) in
//                return
//            }
//
//            alert.addAction(change)
//            alert.addAction(cancel)
//            self.present(alert, animated: true, completion: nil)
//            print(indexPath.row)
//        }
        name = orders[indexPath.row].productName
        time = orders[indexPath.row].time
        dist = orders[indexPath.row].distIndex
        address = orders[indexPath.row].address
        price = orders[indexPath.row].price
        status = orders[indexPath.row].status
        companyID = orders[indexPath.row].companyID
        userID = orders[indexPath.row].userID
        place = orders[indexPath.row].place
        orderAmount = orders[indexPath.row].orderAmount
        performSegue(withIdentifier: "toCompProgress", sender: self)
        
    }
}
