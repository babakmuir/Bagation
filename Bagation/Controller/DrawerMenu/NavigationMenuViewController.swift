//
//  NavigationMenuViewController.swift
//  Bagation
//
//  Created by vivek soni on 24/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import InteractiveSideMenu

class NavigationMenuViewController: MenuViewController {
    @IBOutlet weak var lblUsername                     : UILabel!
    @IBOutlet weak var profileImage                    : UIImageView!
    @IBOutlet weak var btnComplete                    : UIButton!
    let kCellReuseIdentifier = "MenuCell"
    var menuItems = [String]()
    var userType:String! = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        User.shared.loadUser()
        self.lblUsername.text = User.shared.fullname.capitalized(with: NSLocale.current)
        
         userType = SharedProperties.objDefault.value(forKey: Constants.Key_UserLogggedInType) as? String
        if userType == "2" {
            menuItems = ["HOME","STORAGE HISTORY","CHAT","PAYMENT","SETTINGS"]
            self.tableView.reloadData()
        }else {
            menuItems =   ["HOME", "STORAGE HISTORY","CHAT","SETTINGS","BECOME A BAG HANDLER"]
            self.tableView.reloadData()
        }
        
        self.tableView.reloadData()
        // Select the initial row
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        User.shared.loadUser()
        if (User.shared.imagepath.count != 0) {
            //URL.init(string: User.shared.imagepath)!
            //self.profileImage.loadingIndicator(show: true)
            self.profileImage.loadingIndicator(show: true)
            APIManager.downloadImageFrom(strUrl: User.shared.imagepath, callback: { (img) in
                if let image = img{
                    self.profileImage.loadingIndicator(show: false)
                    self.profileImage.contentMode = .scaleAspectFit
                    self.profileImage.image = image
                    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height/2.0
                    self.profileImage.layer.masksToBounds = true
                }
            })
            //self.profileImage.layer.cornerRadius = 30.0
            //self.profileImage.layer.masksToBounds = true
        }
        if (User.shared.userType.count == 0) {
           let strType =  SharedProperties.objDefault.object(forKey: "userType")
            let objUser = User.shared
            objUser.userType = strType as! String
            User.shared.saveUser(user: objUser)
            User.shared.loadUser()
        }
        
        if (User.shared.userType == "1") {
            if (User.shared.phoneno == "") || (User.shared.imagepath == "") || (User.shared.fullname == "") {
                self.btnComplete.isHidden = false
            } else {
                self.btnComplete.isHidden = true
            }
        } else {
            if ((User.shared.phoneno == "") || (User.shared.imagepath == "") || (User.shared.StoreName == "") || (User.shared.BagSpace == "") || (User.shared.BagSpace == "0") || (User.shared.fullname == "")) {
                self.btnComplete.isHidden = false
            } else {
                self.btnComplete.isHidden = true
            }
        }
    }
}

/*
 Extention of `NavigationMenuViewController` class, implements table view delegates methods.
 */
extension NavigationMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = String(format:"  %@",menuItems[indexPath.row])
        cell.textLabel?.font = UIFont.init(name: "GothamRounded-Medium", size: 17.0)
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        cell.isUserInteractionEnabled = true
        let btn  = UIButton()
        btn.frame = cell.bounds
        btn.tag = indexPath.row
        btn.addTarget(self, action: #selector(self.actionButton(sender:)), for: .touchUpInside)
        cell.contentView.addSubview(btn)
        return cell
    }
    
    @objc func actionButton(sender:UIButton) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
   
        if (sender.tag == 4) && (userType == "1" ) {
            let alert = UIAlertController(title: "SignOut!", message: "Travellers must sign out first before signing up as a Bag Handler. Must use alternative email address as a traveller.", preferredStyle: UIAlertControllerStyle.alert)
            
            let action = UIAlertAction(title: "Okay", style: .default) { (alertAction) in
                AppDelegate.objAppDelegate.signOut()
            }
            let actionNo = UIAlertAction(title: "Not Yet", style: .default) { (alertAction) in
                
            }
            alert.addAction(action)
            alert.addAction(actionNo)
            self.present(alert, animated:true, completion: nil)
        } else {
            menuContainerViewController.selectContentViewController(menuContainerViewController.contentViewControllers[sender.tag])
        menuContainerViewController.hideSideMenu()
        }
    }

    @IBAction func completeProfileActionButton (sender:UIButton) {
      
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        
        let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if userType == "2" {
            let updateViewController = storyBoard.instantiateViewController(withIdentifier: "bagHandlerProfileView") as! BagHandlerProfileViewController
            menuContainerViewController.selectContentViewController(updateViewController)
        }else {
            let updateViewController = storyBoard.instantiateViewController(withIdentifier: "updateprofile") as! UpdateProfileViewController
            menuContainerViewController.selectContentViewController(updateViewController)
        }
       
        menuContainerViewController.hideSideMenu()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
       
            menuContainerViewController.selectContentViewController(menuContainerViewController.contentViewControllers[indexPath.row])
            menuContainerViewController.hideSideMenu()
        
    }
}

