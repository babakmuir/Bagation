//
//  NotificationViewController.swift
//  Bagation
//
//  Created by vivek soni on 08/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit

class NotificationViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    
    @IBAction func btnActionForNotification(_ sender: Any) {
        AppDelegate.objAppDelegate.registerForPushNotifications()
        AppDelegate.objAppDelegate.setHomeRootView()
    }
    
    @IBAction func btnActionForClose(_ sender: Any) {
        AppDelegate.objAppDelegate.setHomeRootView()
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
