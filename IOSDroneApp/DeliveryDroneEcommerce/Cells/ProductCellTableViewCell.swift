//
//  ProductCellTableViewCell.swift
//  DeliveryDroneEcommerce
//
//  Created by Michael Peng on 4/9/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit

class ProductCellTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var amountLeft: UILabel!
    @IBOutlet weak var orderedAmt: UILabel!
//    @IBOutlet weak var productImage: UIView!
    @IBOutlet weak var prodImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func addStock(_ sender: Any) {
    }
    
}
