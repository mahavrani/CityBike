//
//  BikeListViewCell.swift
//  CityBike
//
//  Created by Maharani on 16/12/17.
//  Copyright © 2017 Maharani SVS. All rights reserved.

import UIKit

let bikeListViewCell = "BikeListViewCell"
class BikeListViewCell: UITableViewCell {
    @IBOutlet var bikeName: UILabel!
    @IBOutlet var country: UILabel!
    @IBOutlet var bikeId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
