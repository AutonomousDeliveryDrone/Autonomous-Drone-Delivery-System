//
//  ViewController.swift
//  IOS-Swift-UICollectionViewDynamicCustom
//
//  Created by Pooya on 2018-09-25.
//  Copyright © 2018 Pooya. All rights reserved.
//

import UIKit
import Firebase

class ProductViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searching : Bool = false
    
    @IBOutlet weak var collectionView : UICollectionView!
    var colectionArr : [String] = ["1","2","3","4"]
    let titlesF = [("Apple"),("Apricot"),("Banana"),("Grapes"),("Kiwi"),("Orange"),("Peach")]
    let desF = [("$5.00"), ("$25.00"), ("$50.00"), ("$7.00"), ("$13.00"), ("$25.00"), ("$10.00")]
    let imagesF = [UIImage(named: "apple"),
                   UIImage(named: "apricot"),
                   UIImage(named: "banana"),
                   UIImage(named: "grapes"),
                   UIImage(named: "kiwi"),
                   UIImage(named: "orange"),
                   UIImage(named: "peach")]
    
    
    // multiple number to creat font size based on device screen size
    let relativeFontWelcomeTitle:CGFloat = 0.045
    let relativeFontButton:CGFloat = 0.060
    let relativeFontCellTitle:CGFloat = 0.023
    let relativeFontCellDescription:CGFloat = 0.015
    
    
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
    
    var productList: [Product] = []
    var searchedProduct = [Product]()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        ref = Database.database().reference()
        retrieveData()
        // delegate and dataSource
        collectionView.delegate = self
        collectionView.dataSource = self
        //        collectionView.backgroundColor = UIColor.green
        
    }
    
    
    func retrieveData() {
        print(Auth.auth().currentUser!.uid)
        self.ref.child("Storage").child(categoryType).child(company).observeSingleEvent(of: .value, with: { (snapshot) in
            print("Retrieve: \(self.categoryType) + \(self.company)")
            
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
                
                
                let productStorage = Product(name: name, price: price, amount: amount, orderedAmount: orderAmount, desc: desc, link: link, company: company, category: category, companyID: compID, index: index, productImage:image)
                
                self.productList.append(productStorage)
                self.collectionView.reloadData()
            }
        }) { (error) in
            print("error:\(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toUserOrder") {
            let secondVC = segue.destination as! UserOrderViewController
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
            secondVC.previousOrderAmt = orderAmount1
        }
        
        
    }
    
    
    // UICollectionViewDelegate, UICollectionViewDataSource functions
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searching {
         print("hi!")
            return searchedProduct.count
        } else {
            return productList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        
        //let thisElement = colectionArr[indexPath.item]
        let cellIndex = indexPath.item
        let closeFrameSize = bestFrameSize()
        
        var current : Product = productList[indexPath.row]
        if searching {
            current = searchedProduct[indexPath.item]
        } else {
            current = productList[indexPath.item]
        }
//        declare

        cell.labelTitle.text = current.name
        cell.labelTitle.font = cell.labelTitle.font.withSize(closeFrameSize * relativeFontCellTitle)
        let roundedPrice = String(format: "%.2f", current.price)
        cell.labelDetails.text =  "$" + roundedPrice
        cell.labelDetails.font = cell.labelDetails.font.withSize(closeFrameSize * relativeFontCellDescription)
        
        let imageURL = current.productImage
        cell.imageCell?.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "Products"), options: .highPriority, progress: nil, completed: { (downloadImage, downloadException, cacheType, downloadURL) in
            
            if let downloadException = downloadException {
                print("Error downloading an image: \(downloadException.localizedDescription)")
            } else {
                print("Succesfully donwloaded image")
            }
        })
        
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 2
        
        
        cell.imageCell.layer.cornerRadius = 15
        
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.contentView.backgroundColor = UIColor.white
        cell.backgroundColor = UIColor.white
        
        cell.layer.shadowColor = UIColor.white.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        
        
        
        return cell
    }
    
    
    func bestFrameSize() -> CGFloat {
        let frameHeight = self.view.frame.height
        let frameWidth = self.view.frame.width
        let bestFrameSize = (frameHeight > frameWidth ) ? frameHeight : frameWidth
        
        return bestFrameSize
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("hi")
        searchedProduct = productList.filter({$0.name.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searching = false
        searchBar.text = ""
        collectionView.reloadData()
    }
    
}



// extention for UICollectionViewDelegateFlowLayout
extension ProductViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        let heightVal = self.view.frame.height+10
        let widthVal = self.view.frame.width
        let cellsize = (heightVal < widthVal) ?  bounds.height/2 : bounds.width/2
        
        return CGSize(width: cellsize-5 , height:  cellsize  )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (!searching) {
        name1 = productList[indexPath.row].name
        price1 = productList[indexPath.row].price
        desc1 = productList[indexPath.row].desc
        link1 = productList[indexPath.row].link
        index1 = productList[indexPath.row].index
        imageURL = productList[indexPath.row].productImage
        amount1 = productList[indexPath.row].amount
        compID = productList[indexPath.row].companyID
        orderAmount1 = productList[indexPath.row].orderedAmount
        }
        else {
            name1 = searchedProduct[indexPath.row].name
            price1 = searchedProduct[indexPath.row].price
            desc1 = searchedProduct[indexPath.row].desc
            link1 = searchedProduct[indexPath.row].link
            index1 = searchedProduct[indexPath.row].index
            imageURL = searchedProduct[indexPath.row].productImage
            amount1 = searchedProduct[indexPath.row].amount
            compID = searchedProduct[indexPath.row].companyID
            orderAmount1 = searchedProduct[indexPath.row].orderedAmount
        }
        
        
        performSegue(withIdentifier: "toUserOrder", sender: self)
        
        
        
        print(indexPath)
    }
}//end of extension  ViewController
