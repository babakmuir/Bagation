//
//  HUDManager.swift
//  PigeonShip
//
//  Created by Vivek on 13/12/17.
//  Copyright © 2017 PigeonShip Inc. All rights reserved.
//

import UIKit
import BLMultiColorLoader

class HUDManager: NSObject {
    var overlayView         : UIView = UIView()
    var appDelegate         : AppDelegate = AppDelegate.objAppDelegate

    class var sharedInstance: HUDManager {
        struct Static {
        static let instance: HUDManager = HUDManager()
        }
        return Static.instance
    }
    
    func showHud() {
        self.hideHud()
        if (overlayView.superview != nil) {
            overlayView.removeFromSuperview()
        }
        overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.layer.opacity           = 0.5
        overlayView.backgroundColor         = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
        overlayView.tag                     = 99999
        let multiColorLoader = BLMultiColorLoader(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        multiColorLoader.lineWidth = 3.0
        multiColorLoader.colorArray = [Constants.primaryColor,Constants.RedColor,Constants.whiteColor,Constants.BlueColor,Constants.GreenColor]
        multiColorLoader.startAnimation()
        overlayView.addSubview(multiColorLoader)
        multiColorLoader.center = CGPoint(x: overlayView.center.x, y: overlayView.center.y)
        appDelegate.window!.addSubview(overlayView)

    }
    func hideHud() {
        if (appDelegate.window?.viewWithTag(99999)?.superview != nil){
            appDelegate.window?.viewWithTag(99999)?.removeFromSuperview()
        }
    }

}
