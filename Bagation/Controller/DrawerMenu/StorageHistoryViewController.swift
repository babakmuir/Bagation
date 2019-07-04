//
//  StorageHistoryViewController.swift
//  Bagation
//
//  Created by vivek soni on 24/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import SwipeCellKit
import SafariServices

class StorageHistoryViewController: UIViewController,SideMenuItemContent,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblNoFound: UILabel!
    
    var availablePackage = [StorageDAO]()
    var arrStorageData : [Any] = []
    //var chatList = [Inbox]()
    
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
        
        self.getUserStoragHistory()
        //self.getConversationList()
    }
    
    func getUserStoragHistory(){
        Utility.showHUD(msg: "")
            self.availablePackage = []
            self.tableView.reloadData()
            let  param = ["UserID":User.shared.userId] as [String : Any]
            APIManager.getRequestWith(strURL: Constants.requestAPIOrderDetails, Param: param) { (Dict, Error) in
                if Error == nil {
                    Utility.hideHUD()
                    self.refreshControl.endRefreshing()
                    self.availablePackage = []
                    if let data = Dict!["GetAllOrderDetailsResult"] {
                        let array:[Any] = data as! [Any]
                        
                    print(array)
                        self.arrStorageData = array
                        for obj in array {
                            let store = StorageDAO(storageDict: obj as! [String : Any])
                            self.availablePackage.append(store)
                        }
                        if (self.availablePackage.count == 0){
                            self.lblNoFound.isHidden = false
                        } else {
                            self.lblNoFound.isHidden = true
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            }
    }
    
    /*func getConversationList(){
        self.chatList = [Inbox]()
        FireBaseManager.sharedInstance.getInboxList { (results, errorMSG) in
            if (errorMSG?.isEmpty)! {
                self.chatList = results!
            }
        }
    }*/
    
    func convertDateToFormattedString (string: String,endDate: String) -> String {
        
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
        let str = newDate + "-" + newDateEnd
        return str
    }
    
    
    // MARK: - Method
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getUserStoragHistory()
    }
    
    @objc func openMenuAction(){
        showSideMenu()
    }
   
    
    @IBAction func openMenu(_ sender: UIButton) {
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
        cell.lblStorageName.text = store.StoreName
        cell.lblAddress.text = store.Address
        //
        
        if (store.NoOfBags == "1") {
            
            cell.lblBagCount.text = "\(store.NoOfBags!) Bag"
            
        } else {
            
            cell.lblBagCount.text = "\(store.NoOfBags!) Bags"
            
        }
        
        cell.lblDateTime.text = self.convertDateToFormattedString(string: store.StartDate,endDate: store.EndDate)
        cell.lblDateTime.adjustsFontSizeToFitWidth = true
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {

//        let obj = storyboard?.instantiateViewController(withIdentifier: "StorageDetailViewController") as! StorageDetailViewController
//        obj.arrData = arrStorageData[indexPath.row] as! [String : Any]
//        navigationController?.pushViewController(obj, animated: true)
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

extension StorageHistoryViewController:SwipeTableViewCellDelegate {
  
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let store = self.availablePackage[indexPath.row]
        let call = SwipeAction(style: .default, title: nil) { (action, indexPath) in
            self.callAction(phone: store.BagHanlderPhone)
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

