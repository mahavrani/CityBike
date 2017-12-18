//
//  StationTableViewCell.swift
//  CityBike
//
//  Created by Maharani on on 16/12/17.
//  Copyright © 2017 Maharani SVS. All rights reserved.
//

import UIKit
let stationTableViewCell = "StationTableViewCell"
class StationTableViewCell: UITableViewCell {
    @IBOutlet weak var stationVal: UILabel!
    @IBOutlet weak var emptySlotsVal: UILabel!
    @IBOutlet weak var freeBikesVal: UILabel!
    @IBOutlet weak var locationBtn: UIButton!
    
    var selectionCallback: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK :: -  Call Back Action Method to pass data on each click of Location icon in Station
    @IBAction func mapAction(_ sender: Any) {
        if let selectionCallback = self.selectionCallback{
            selectionCallback()
        }
    }
    
    //MARK :: -  Action to load Station Details
    func loadDetails(object : Stations) {
        DispatchQueue.main.async {
            self.stationVal?.text = object.stationName?.isEmpty == false ?  object.stationName : ""
            self.freeBikesVal?.text = object.freeBikes?.isEmpty == false ?  object.freeBikes : ""
            self.emptySlotsVal?.text = object.emptySlots?.isEmpty == false ?  object.emptySlots : ""
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
