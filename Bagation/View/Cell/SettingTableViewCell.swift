//
//  SettingTableViewCell.swift
//  Bagation
//
//  Created by vivek soni on 01/02/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    @IBOutlet weak var lblItemName             : UILabel!
    @IBOutlet weak var lblVersionNo             : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func reloadCategoryData(dict: NSDictionary) {
        self.lblItemName.text = dict.value(forKey: "title") as! String?
    }
    
}
