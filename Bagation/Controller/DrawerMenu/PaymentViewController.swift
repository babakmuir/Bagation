//
//  PaymentViewController.swift
//  Bagation
//
//  Created by vivek soni on 24/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import InteractiveSideMenu

class PaymentViewController: UIViewController,SideMenuItemContent {

    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var lblLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigation()
        let img = #imageLiteral(resourceName: "icon-menu")
        if let parent = self.parent {
            let btnback = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.openMenuAction))
            parent.navigationItem.leftBarButtonItem = btnback
            parent.title = "Payment"
        }
        
        if (SharedProperties.objDefault.value(forKey: "StripAccountID") != nil) {
            self.btnConnect.isHidden = true
            self.lblLabel.text = "You have Successfully connected with Stripe Account."
        } else {
             self.btnConnect.isHidden = false
        }
    }
    
    @objc func openMenuAction(){
        showSideMenu()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
