//
//  CompanyOrderCell.swift
//  DeliveryDroneEcommerce
//
//  Created by Gavin Wong on 4/13/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit

class CompanyOrderCell: UITableViewCell {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var timePurchased: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var customerAddress: UILabel!
//    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
