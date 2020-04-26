//
//  UserHomeViewController.swift
//  DeliveryDroneEcommerce
//
//  Created by Michael Peng on 4/8/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase

class UserHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var categories: [Category] = [
        Category(categoryType: "Food"),
        Category(categoryType: "Supplies"),
        Category(categoryType: "Gadgets"),
        Category(categoryType: "Clothing"),
        Category(categoryType: "Stationaries")
    ]
    
    var images: [UIImage] = [
        UIImage(named: "Food")!,
        UIImage(named: "Supplies")!,
        UIImage(named: "Gadgets")!,
        UIImage(named: "Clothings")!,
        UIImage(named: "Stationaries")!
    ]
    
    var categorySelected: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: "ReusableCell" )
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCompaniesDisplay") {
            let secondVC = segue.destination as! DisplayedCompanyViewController
            secondVC.category = categorySelected
        }
    }
    
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "userBack", sender: self)
            
        }catch let signOutError as NSError {
            print("Logout Error")
        }
        
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

extension UserHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
        //might need to change later if we decide to add more categories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! CategoryCell
        
        cell.categoryLabel.text = categories[indexPath.row].categoryType
        cell.categoryImage.image = images[indexPath.row]
        return cell
    }
}

extension UserHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        categorySelected = categories[indexPath.row].categoryType
        performSegue(withIdentifier: "toCompaniesDisplay", sender: self)
    }
}
