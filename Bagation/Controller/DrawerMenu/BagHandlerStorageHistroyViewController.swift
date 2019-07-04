//
//  BagHandlerStorageHistroyViewController.swift
//  Bagation
//
//  Created by vivek soni on 24/02/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import SwipeCellKit

class BagHandlerStorageHistroyViewController: UIViewController,SideMenuItemContent,UITableViewDataSource,UITableViewDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblNoFound: UILabel!
    
    var availablePackage = [StorageDAO]()
    
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        
        refreshControl.tintColor = Constants.primaryColor
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(self.refreshControl)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigation()
        let img = #imageLiteral(resourceName: "icon-menu")
        if let parent = self.parent {
            let btnback = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.openMenuAction))
            parent.navigationItem.leftBarButtonItem = btnback
            parent.title = "Storage History"
        }
        
        //self.getUserStoragHistory()
        self.CallApiForLogin()
    }
 
    func callWebServiceForReleaseSpace(storage:StorageDAO) {
        Utility.showHUD(msg: "")
        var strBags : String = storage.NoOfBags
        strBags = strBags.replacingOccurrences(of: " Bag", with: "")
        User.shared.loadUser()
        let objUser = User.shared
        if (objUser.userId.count == 0) {
            let strId = UserDefaults.standard.object(forKey: Constants.key_UserID)
            objUser.userId = strId as! String
        }
        
        //let param = ["userid":objUser.userId,"BagHandlerID":storage.BagHandlerID,"NoOfBags":strBags,"OrderID":storage.OrderID] as [String : Any]
        let param = ["userid":objUser.userId,"BagHandlerID":String(Int(storage.BagHandlerID)!),"NoOfBags":strBags,"OrderID":String(Int(storage.OrderID)!)] as [String : Any]
        
        print(param)
        APIManager.getRequestWith(strURL: Constants.requestAPIReleaseSpace, Param: param) { (Dict, Error) in
            if Error == nil {
                print(Dict ?? "")
                Utility.hideHUD()
                if ((Dict?.object(forKey: "code")) as! Int == 100) {
                    self.getUserStoragHistory()
                    self.showAlert(strMessage: "Space has been released.")
                }
                self.tableView.reloadData()
            } else {
                self.lblNoFound.isHidden = false
            }
        }
    }
    
    
    func getUserStoragHistory() {
        Utility.showHUD(msg: "")
        let  param = ["UserID":User.shared.userId,"StartDate":"","EndDate":""] as [String : Any]
        print(param)
        APIManager.getRequestWith(strURL: Constants.requestAPICalender, Param: param) { (Dict, Error) in
            if Error == nil {
                Utility.hideHUD()
                self.refreshControl.endRefreshing()
                self.lblNoFound.isHidden = true
                self.availablePackage = []
                print(Dict ?? "")
                if let data = Dict!["GetAllOrderDetailsByBagHandlerIDResult"] {
                    let array:[Any] = data as! [Any]
                    for obj in array {
                        let store = StorageDAO(storageDict: obj as! [String : Any])
                        if (!self.enddating(endTime: store.EndDate)) {
                            self.availablePackage.append(store)
                        }
//                        self.availablePackage.append(store)
                    }
                    if (self.availablePackage.count == 0){
                         self.lblNoFound.isHidden = false
                    } else {
                        self.availablePackage = self.availablePackage.reversed()
                    }
                    self.tableView.reloadData()
                }
            } else {
                self.lblNoFound.isHidden = false
            }
        }
    }
    
//    func enddating(endTime: String)-> Bool {
//        let currentDate = Date()
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.Z"
//        let endTimeFormat = dateFormatter.date(from: endTime)
//        let laterDate = endTimeFormat!.addingTimeInterval(1800)
//
//        if currentDate < laterDate {
//            return true
//        }
//        return false
//    }
    
    func enddating(endTime: String)-> Bool {
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let endTimeFormat = dateFormatter.date(from: endTime)
        let laterDate = endTimeFormat!.addingTimeInterval(1800)
        
        if currentDate < laterDate {
            return true
        }
        return false
    }
    
    func CallApiForLogin(){
        if (AppDelegate.objAppDelegate.isConnectedToInternet()) {
            Utility.showHUD(msg: "")
            
            //DeviceType = 1 for ios
            
            if UserDefaults.standard.object(forKey: Constants.Key_DeviceToken) == nil {
                UserDefaults.standard.set("", forKey: Constants.Key_DeviceToken)
            }
            let userObj = User.shared
            
            let strToken = UserDefaults.standard.value(forKey: Constants.Key_DeviceToken) as! String
            let value = ["email": userObj.email, "password": userObj.password, "devicetoken":strToken,"fbid":"" ,"IsAdminLogin":"0","DeviceType":"1","UserType": "2"]
            
            APIManager.getRequestWith(strURL: Constants.requestAPILogin, Param: value) { (Dict, Error) in
                Utility.hideHUD()
                if Error == nil {
                    if let value = Dict {
                        print(value)
                        if ((value.object(forKey: "ResponseCode")) as! Int == 200) {
                            var valueToStore =  [String: Any]()
                            var imagePath : String = ""
                            
                            imagePath = value.value(forKey: "ProfilePhoto") as! String
                            let userType = String (describing: value.value(forKey: "UserType")!)
                            let userID = String (describing:value.value(forKey: "UserID")!)
                            
                            Constants.objDefault.set(userID, forKey: Constants.key_UserID)
                            if userType == "2" {
                                let userID = String (describing:value.value(forKey: "UserID")!)
                                let startTime = String (describing:value.value(forKey: "StartTime")!)
                                let endTime = String (describing:value.value(forKey: "EndTime")!)
                                if (value.object(forKey: "StripAccountID") != nil) {
                                    let strId = value.object(forKey: "StripAccountID") as! String
                                    if(strId.count != 0) {
                                        SharedProperties.objDefault.set(strId, forKey: "StripAccountID")
                                    }
                                }
                                //StripAccountID
                                valueToStore = ["email":userObj.email,"password": userObj.password,"fullname":value.value(forKey: "DisplayName") ?? "","fbid":"","phoneno":value.value(forKey: "Phone") ?? "","deviceToken":strToken,"userId":userID,"imagepath":imagePath,"userType":userType,"Address":value.value(forKey: "Address") ?? "","StoreName":value.value(forKey: "StoreName") ?? "","StoreDesc":value.value(forKey: "StoreDesc") ?? "","BagSpace":value.value(forKey: "BagSpace") ?? "","latitude":value.value(forKey: "Latitude") ?? "","longitude":value.value(forKey: "Longitude") ?? "","StartTime":startTime,"EndTime":endTime] as [String : Any]
                                
                            }
                            
                            print(valueToStore)
                            let user = User.init(dic: valueToStore)
                            User.shared.saveUser(user: user)
                            SharedProperties.setLoggedIn()
                            
                            FireBaseManager.sharedInstance.loginUser(email: user.email, callback: { (_, _) in
                            })
                            
                            self.getUserStoragHistory()
                        } else {
                            self.showAlert(strMessage: (value.object(forKey: "Message")) as! String)
                        }
                    }
                } else {
                    //self.showAlert(strMessage: "")
                    let alert = UIAlertController(title: "Alert!", message: "Session expired. Please Sign In again.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let action = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                        AppDelegate.objAppDelegate.signOut()
                    }
                    alert.addAction(action)
                    self.present(alert, animated:true, completion: nil)
                }
            }
        } else {
            self.showAlert(strMessage: Constants.errorNetworkMessage)
        }
    }
    
    // MARK: - Method
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getUserStoragHistory()
    }
    
    @objc func openMenuAction(){
        showSideMenu()
    }
    
    func callAction(phone:String){
        if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
    }
    
    func convertDateToFormattedString (string: String, endDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //Current time zone
        let date = dateFormatter.date(from: string) //according to date format your date string
        let dateEnd = dateFormatter.date(from: endDate) //according to date format your date
        
        dateFormatter.dateFormat = "dd MMM hh:mm a" //Your New Date format as per requirement change it own
        //dateFormatter.dateStyle = DateFormatter.Style.medium
        //dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = TimeZone.current
        let newDate = dateFormatter.string(from: date!) //pass Date here
        let newDateEnd = dateFormatter.string(from: dateEnd!) //pass Date here
        var str = newDate + "-" + newDateEnd
        
        let days=Calendar.current.dateComponents([.hour,.minute,.second], from: NSDate() as Date, to: dateEnd!)
        
        let nb_hours = days.hour
        let nb_minute = days.minute
        if (nb_hours! <= 0 && nb_minute! <= 0) {
            str = str + " Expired"
        }
    
        return str
    }
    
    @objc func btnMenuAction(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        let index = IndexPath(row: sender.tag, section: 0)
        
        if let cell = self.tableView.cellForRow(at: index) {
            if sender.isSelected {
                (cell as! StorageHistoryTableViewCell).showSwipe(orientation: .right, animated: true, completion: { (_) in
                    
                })
            }else {
                (cell as! StorageHistoryTableViewCell).hideSwipe(animated: true, completion: { (_) in
                    
                })
            }
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availablePackage.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell:StorageHistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! StorageHistoryTableViewCell? else {
            return UITableViewCell()
        }
        let store = self.availablePackage[indexPath.row]
        cell.lblStorageName.text = store.DisplayName
        cell.lblAddress.text = String(format:"Total Amount: $ %@",store.TotalAmount)
        cell.lblDateTime.text = self.convertDateToFormattedString(string: store.StartDate,endDate:store.EndDate)
        if (cell.lblDateTime.text?.contains("Expired"))! {
            cell.lblDateTime.textColor = UIColor.red
            cell.lblBagCount.textColor = UIColor.red
            
        }
        cell.lblDateTime.adjustsFontSizeToFitWidth = true
        if (store.SpaceReleasedStatus == "1") {
             cell.lblBagCount.text = "0 Bag"
        } else {
             cell.lblBagCount.text = store.NoOfBags
        }
        //        let dictData = self.availablePackage[indexPath.row] as! Dictionary<String, Any>
        //        cell.reloadPackageData(dict: dictData as NSDictionary)
        cell.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.btnMenuIcon.tag = indexPath.row
        cell.btnMenuIcon.addTarget(self, action: #selector(self.btnMenuAction(sender:)), for: .touchUpInside)
        if (store.PaymentStatus == "1") {
            cell.imgStatusIcon.image = UIImage(named:"cancel")
        } else {
            cell.imgStatusIcon.image = UIImage(named:"checked")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let dictData = (self.availablePackage[indexPath.row] as! Dictionary<String, Any>) as NSDictionary
        //        let url = dictData.value(forKey: "url")
        //
        //        let sfViewController = SFSafariViewController(url: NSURL(string:url as! String)! as URL, entersReaderIfAvailable: false)
        //        self.present(sfViewController, animated: true, completion: nil)
        
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

extension BagHandlerStorageHistroyViewController:SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let store = self.availablePackage[indexPath.row]
        
        let storage = SwipeAction(style: .default, title: nil) { (action, indexPath) in
            
            if (store.SpaceReleasedStatus == "1") {
                let alert = UIAlertController(title: "Storage Released", message: "Space has already released for this booking.", preferredStyle: UIAlertControllerStyle.alert)
                
                let action = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                    
                }
                alert.addAction(action)
                self.present(alert, animated:true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Storage Release", message: "Are you sure you want to release?", preferredStyle: UIAlertControllerStyle.alert)
                
                let action = UIAlertAction(title: "Yes", style: .default) { (alertAction) in
                    self.callWebServiceForReleaseSpace(storage:store)
                }
                let actionNo = UIAlertAction(title: "No", style: .default) { (alertAction) in
                    
                }
                alert.addAction(action)
                alert.addAction(actionNo)
                self.present(alert, animated:true, completion: nil)
            }
        }
        
        // customize the action appearance
        storage.image = UIImage(named:"storage")
        storage.backgroundColor = .clear
        
        
        
        let call = SwipeAction(style: .default, title: nil) { (action, indexPath) in
             self.callAction(phone: store.Phone!)
        }
        // customize the action appearance
        call.image = #imageLiteral(resourceName: "call")
        call.backgroundColor = .clear
        
        
        let chat = SwipeAction(style: .default, title: nil) { (action, indexPath) in
            let obj:ConversationViewController = self.storyboard?.instantiateViewController(withIdentifier: "conversationView") as! ConversationViewController
            obj.objUser = store
            self.navigationController?.pushViewController(obj, animated: true)
        }
        // customize the action appearance
        chat.backgroundColor = .clear
        chat.image = #imageLiteral(resourceName: "chat")
        
        
        return [call,chat]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.transitionStyle = .reveal
        return options
    }
}
