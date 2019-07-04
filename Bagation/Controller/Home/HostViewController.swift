//
//  HostViewController.swift
//  Bagation
//
//  Created by vivek soni on 24/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import InteractiveSideMenu

class HostViewController: MenuContainerViewController {

    var userType:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        self.transitionOptions = TransitionOptions(duration: 0.4, visibleContentWidth: screenSize.width / 6)
        
        // Instantiate menu view controller by identifier
        self.menuViewController = self.storyboard!.instantiateViewController(withIdentifier: "NavigationMenu") as? MenuViewController
        
        // Gather content items controllers
        self.contentViewControllers = contentControllers()
        
        // Select initial content controller. It's needed even if the first view controller should be selected.
        self.selectContentViewController(contentViewControllers.first!)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        /*
         Options to customize menu transition animation.
         */
        var options = TransitionOptions()
        
        // Animation duration
        options.duration = size.width < size.height ? 0.4 : 0.6
        
        // Part of item content remaining visible on right when menu is shown
        options.visibleContentWidth = size.width / 6
        self.transitionOptions = options
    }
    
    private func contentControllers() -> [UIViewController] {
        
        var controllersIdentifiers = [String]()
        if (self.userType == "1") {
             controllersIdentifiers = ["mapViewController","storagehistory","chatView","settingView","bagHandlerSignupView"]
        } else {
            controllersIdentifiers = ["calenderView","bagHandlerStorage","chatView","paymentView","settingView"]
        }
   
        var contentList = [UIViewController]()
        
        /*
         Instantiate items controllers from storyboard.
         */
        for identifier in controllersIdentifiers {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier) {
                contentList.append(viewController)
            }
        }
        
        return contentList
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
