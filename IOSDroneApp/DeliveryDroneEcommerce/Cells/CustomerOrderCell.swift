//
//  CustomerOrderCell.swift
//  DeliveryDroneEcommerce
//
//  Created by Gavin Wong on 4/13/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit

class CustomerOrderCell: UITableViewCell {


    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var status: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
