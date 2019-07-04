//
//  StorageHistoryTableViewCell.swift
//  Bagation
//
//  Created by vivek soni on 30/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit

import SwipeCellKit

class StorageHistoryTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var lblStorageName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblBagCount: UILabel!
    @IBOutlet weak var btnMenuIcon: UIButton!
    @IBOutlet weak var imgStatusIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reloadPackageData(dict: NSDictionary) {
    //    let dicCollection = ((((dict.value(forKey: "orders") as! NSArray?)?.firstObject) as! NSDictionary).value(forKey: "collection_point")) as! NSDictionary
        
        
        
//        self.lblPickUpAddress.text = String(format:"%@, %@, %@, %@",dicCollection.value(forKey: "street") as! String,dicCollection.value(forKey: "town") as! String, dicCollection.value(forKey: "state") as! String, dicCollection.value(forKey: "zip") as! String)
        
    
        
//
//        let intPrice:NSNumber = dict.value(forKey: "pigeon_pay") as! NSNumber
//        let totalPrice = (intPrice.floatValue / 100)
//        self.lblPayPrice.text = String(format:"$%.2f",totalPrice)
//        self.lblPayPrice.adjustsFontSizeToFitWidth = true;
//
//        self.lblCollectionDate.text = String(format:"Pickup Date: %@",Utility.convertUTCToLocal(strDate: dict.value(forKey: "collection_date") as! CVarArg as! String))
//
    }
    

}
