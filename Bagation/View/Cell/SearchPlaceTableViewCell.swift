//
//  SearchPlaceTableViewCell.swift
//  Bagation
//
//  Created by vivek soni on 24/02/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit

class SearchPlaceTableViewCell: UITableViewCell {
    @IBOutlet weak var lblStorageName: UILabel!
    @IBOutlet weak var lblPriceAvailability: UILabel!
    @IBOutlet weak var lblSapceAvailability: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnBooknow: UIButton!
    @IBOutlet weak var lblDays: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
