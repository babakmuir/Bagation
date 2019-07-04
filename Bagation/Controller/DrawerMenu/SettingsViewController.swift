//
//  SettingsViewController.swift
//  Bagation
//
//  Created by vivek soni on 24/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import InteractiveSideMenu


class SettingsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate ,SideMenuItemContent{

    @IBOutlet weak var tableView : UITableView!
//    @IBOutlet weak var viewDays: UIView!
    @IBOutlet weak var btnMon: UIButton!
    @IBOutlet weak var btnTue: UIButton!
    @IBOutlet weak var btnWed: UIButton!
    @IBOutlet weak var btnThurs: UIButton!
    @IBOutlet weak var btnFri: UIButton!
    @IBOutlet weak var btnSat: UIButton!
    @IBOutlet weak var btnSun: UIButton!

//    var array = [ ["Terms of Service"],
//                  ["Version", "Log Out"]]  //"Payment Method",
    
    var array = [ ["Terms of Service"],
                  ["Version", "Log Out"]]
    
    var onlineStatus = ""
    var bagHandlerID : Int?
    var arrBagHandlerID : [Int] = []
    var arrIsOnline : [String] = []
    var userType = ""
//    var isMonCheck : Bool?
//    var isTueCheck : Bool?
//    var isWedCheck : Bool?
//    var isThursCheck : Bool?
//    var isFriCheck : Bool?
//    var isSatCheck : Bool?
//    var isSunCheck : Bool?
    var arrDays : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.value(forKey: "IsOnline") != nil
        {
            onlineStatus = UserDefaults.standard.value(forKey: "IsOnline") as! String
        }

        if UserDefaults.standard.value(forKey: "bagHandlerIDArray") != nil
        {
            arrBagHandlerID = (UserDefaults.standard.value(forKey: "bagHandlerIDArray") as? [Int])!
        }
        if UserDefaults.standard.value(forKey: "userType") != nil
        {
            userType = UserDefaults.standard.value(forKey: "userType") as! String
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        viewDays.isHidden = true
        let strId = UserDefaults.standard.object(forKey: Constants.key_UserID) as? String
        bagHandlerID = Int(strId!)
//        bagHandlerID = strId
        configureNavigation()
        let img = #imageLiteral(resourceName: "icon-menu")
        if let parent = self.parent {
            let btnback = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.openMenuAction))
            parent.navigationItem.leftBarButtonItem = btnback
            parent.title = "Settings"
        }
        tableView.reloadData()
    }
    
    @objc func openMenuAction(){
        showSideMenu()
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        showSideMenu()
        
    }
    
    func logout() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        
        let action = UIAlertAction(title: "Yes", style: .default) { (alertAction) in
            AppDelegate.objAppDelegate.signOut()
        }
        let actionNo = UIAlertAction(title: "No", style: .default) { (alertAction) in
            
        }
        alert.addAction(action)
        alert.addAction(actionNo)
        self.present(alert, animated:true, completion: nil)
    }

    //Mark: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.array.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0) && self.userType == "1"
            {
                return 0.0
            }
            if (indexPath.row == 2) && self.userType == "1"
            {
                return 0.0
            }
        }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell:SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SettingTableViewCell? else {
            return UITableViewCell()
        }
        print("array is:", self.array)
        let strItem = self.array[indexPath.section][indexPath.row] as String
        cell.lblItemName.text = strItem
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0)
            {
//                let mySwitch = UISwitch()
//                mySwitch.center = view.center
////                mySwitch.setOn(false, animated: false)
//                mySwitch.addTarget(self, action: #selector(switchChanged(sender:)), for: UIControlEvents.valueChanged)
//                cell.accessoryView = mySwitch
//
//                if onlineStatus == "0"
//                {
//                    mySwitch.isOn = false
//                    array = [ ["Status INACTIVE:", "Terms of Service", "Store Open Days:" ],
//                              ["Version", "Log Out"]]
//                }
//                else if onlineStatus == "1"
//                {
//                    mySwitch.isOn = true
//                    array = [ ["Status ACTIVE:", "Terms of Service", "Store Open Days:" ],
//                              ["Version", "Log Out"]]
//                }
//
//                if (UserDefaults.standard.object(forKey: "SwitchState") != nil) {
//                    mySwitch.isOn = UserDefaults.standard.bool(forKey: "SwitchState")
//                }
//                if mySwitch.isOn == true
//                {
//                    onlineStatus = "1"
//                    array = [ ["Status ACTIVE:", "Terms of Service", "Store Open Days:" ],
//                              ["Version", "Log Out"]]
//                }
//                else if mySwitch.isOn == false
//                {
//                    onlineStatus = "0"
//                    array = [ ["Status INACTIVE:", "Terms of Service", "Store Open Days:" ],
//                              ["Version", "Log Out"]]
//                }
                
            }
            else if (indexPath.row == 0)
            {
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            else if (indexPath.row == 1)
            {
//                let myButton = UIButton(type: UIButtonType.custom)
//                myButton.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
//                myButton.backgroundColor = UIColor.blue
//                myButton.titleLabel?.font = UIFont(name: "GothamRounded-Medium 16.0", size: 12.0)
//                myButton.setTitle("Select Days", for: .normal)
//                myButton.addTarget(self, action: #selector(btnDaysTapped(sender:)), for: UIControlEvents.touchUpInside)
//                cell.accessoryView = myButton as UIView
                
            }
            
        } else {
            if (indexPath.row == 0) {
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    cell.lblVersionNo.text = version
                }
            } else {
                cell.lblItemName.textColor = UIColor.red
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            
            let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            switch indexPath.row {
          /*  case 0: //Payment
//                let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let manageViewController = storyBoard.instantiateViewController(withIdentifier: "manageAccount") as! ManageAccountViewController
//                manageViewController.isFromSetting = true
//                self.navigationController?.pushViewController(manageViewController, animated: true)
                break*/
                
            case 0:
                let termsViewController = storyBoard.instantiateViewController(withIdentifier: "termsServices") as! TermsServicesViewController
                self.present(termsViewController, animated: true, completion: nil)
                break
//
//            case 1:
//
//                let updatePasswordController = storyBoard.instantiateViewController(withIdentifier: "updatePassword") as! UpdatePasswordViewController
//
//                self.present(updatePasswordController, animated: true, completion: nil)
//
//                print("UPDATE PASSWORD")
                
            default:
                break
            }
        }
        
        if (indexPath.section == 1) {
            switch indexPath.row {
            case 0:
                break
            case 1:
                self.logout()
                break
                
            default:
                break
            }
        }
    }
    
    func insertElementAtIndex(element: String?, index: Int)
    {
        while arrDays.count <= index
        {
            arrDays.append("")
        }
        arrDays.insert(element!, at: index)
    }

}
