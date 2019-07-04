//
//  CalenderViewController.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import FSCalendar
import InteractiveSideMenu

class CalenderViewController: UIViewController,SideMenuItemContent {

    @IBOutlet weak var calenderView: FSCalendar!
    @IBOutlet weak var tblEvent: UITableView!
    @IBOutlet weak var lblNoResult: UILabel!

    var events = [EventDAO]()
    var selectedDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
      //  FireBaseManager.sharedInstance.signupUser(email:"push@gmail.com")
//        FireBaseManager.sharedInstance.loginUser(email: "push@gmail.com", callback: { (_, _) in
//        })
        //CallApiForLogin()
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getUserStoragHistory()
        
        configureNavigation()
        let img = #imageLiteral(resourceName: "icon-menu")
        if let parent = self.parent {
            let btnback = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.openMenuAction))
            parent.navigationItem.leftBarButtonItem = btnback
            
            /*let btn2 = UIButton(type: .custom)
            btn2.contentMode = .scaleAspectFill
            btn2.setImage(UIImage(named: "chat"), for: .normal)
            btn2.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            btn2.addTarget(self, action: #selector(self.openChatAction), for: .touchUpInside)
            let btnChat = UIBarButtonItem(customView: btn2)
            parent.navigationItem.rightBarButtonItem = btnChat
            */
           // parent.title = "Calender"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let parent = self.parent {
            parent.navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc func openMenuAction(){
        showSideMenu()
    }
    @objc func openChatAction(){
        let obj:ChatViewController = self.storyboard?.instantiateViewController(withIdentifier: "chatView") as! ChatViewController
        obj.strNav = "YES"
        if let parent = self.parent {
            parent.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    func CallApiForLogin() {
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
    
    func getUserStoragHistory(){
        //2018-11-08
         Utility.showHUD(msg: "")
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let now = dateformatter.string(from: Date())
        print(now)
        let end = Calendar.current.date(byAdding: .day, value: 60, to: Date())
        let endDate = dateformatter.string(from: end!)
        print(endDate)
        let  param = ["UserID":User.shared.userId,"StartDate":now,"EndDate":endDate] as [String : Any]
        print(param)
        APIManager.getRequestWith(strURL: Constants.requestAPICalender, Param: param) { (Dict, Error) in
             Utility.hideHUD()
            if Error == nil {
               
                print("Dict is: \(Dict!["GetAllOrderDetailsByBagHandlerIDResult"])")
                self.events = []
                self.lblNoResult.isHidden = true
                if let data = Dict!["GetAllOrderDetailsByBagHandlerIDResult"] {
                 let array:[Any] = data as! [Any]
                    for obj in array {
                        let dic = obj as! NSDictionary
                        if (dic.value(forKey: "IsReleased") as! String == "0") {
                            let event = EventDAO(eventDict: obj as! [String : Any])
                            self.events.append(event)
                        }
                    }
                    if self.events.count == 0 {
                        self.lblNoResult.isHidden = false
                    }
                    self.tblEvent.reloadData()
                }
            }
        }
    }
    
    func gotoEventsView(){
        let obj =  EventsViewController()
        obj.currentDate = self.selectedDate
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    func dayDifference(from date : Date) -> String
    {
        let calendar = NSCalendar.current
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        else if calendar.isDateInToday(date) { return "Today" }
        else if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        else {
            let startOfNow = calendar.startOfDay(for: Date())
            let startOfTimeStamp = calendar.startOfDay(for: date)
            let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
            let day = components.day!
            if day < 1 { return "\(abs(day)) days ago" }
            else { return "In \(day) days" }
        }
    }
    
    func convertTime(date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    
    @IBAction func openMenu(_ sender: UIButton) {
        showSideMenu()
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

extension CalenderViewController:FSCalendarDelegate,FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("date")
        self.selectedDate = date
        self.gotoEventsView()
        
    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
       
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if date == Date() {
            return 2
        }else {
            return 0
        }
    }
    
}

extension CalenderViewController:UITableViewDelegate,UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if events.count > 2 {
            return 2//events.count
        }else {
            return events.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:EventCell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell? else {
             return UITableViewCell()
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let event = events[indexPath.row]
//        cell.lblTime.text = self.dayDifference(from: event.StartDate!) + " at \(self.convertTime(date:  event.StartDate!))"
        cell.lblTime.text = self.dayDifference(from: event.StartDate!) + " at \(self.convertTime(date:  event.StartDate!)) - \(self.convertTime(date: event.EndDate!))"
//        cell.lblUserName.text = event.DisplayName.capitalized
        cell.lblUserName.text = "Name: " + event.DisplayName.capitalized
        cell.lblCount.text = event.OrderID
        if indexPath.row % 2 == 0 {
            cell.viewSideColor.backgroundColor = Constants.eventColor1
        }else {
            cell.viewSideColor.backgroundColor = Constants.eventColor2
        }
        return cell
   }
}
