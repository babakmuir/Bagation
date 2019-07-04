//
//  BookingViewController.swift
//  Bagation
//
//  Created by vivek soni on 09/02/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import Stripe
import UserNotifications
import Alamofire
class BookingViewController: UIViewController,UITextFieldDelegate,STPAddCardViewControllerDelegate {

//    private enum PP {
//
//        case pickerfrom
//        case pickerTo
//
//    }
//
//    private var pp: PP = .pickerfrom
    
    @IBOutlet var lblAddress: UILabel!
    
    @IBOutlet var lblFrom: UILabel!
    @IBOutlet var lblTo: UILabel!
    @IBOutlet weak var availableSpace: UILabel!
    @IBOutlet var lblTotal: UILabel!
    @IBOutlet var txtBags: UITextField!
    @IBOutlet var txtFrom: UITextField!
    @IBOutlet var txtTo: UITextField!
    var dicBagHanlderDetail: [String : Any] = [:]
    var clientToken = ""
    var clientNonce = ""
    var orderId = ""
    var spaceAvailable : Int = 0
    var startUTCDate = Date()
    var endUTCDate = Date()
    var days = ""
    var arrDays : [String] = []
    var arrWeekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var last10 = ""
    var last101 = ""
    var indValueStart : Int?
    var indValueStop : Int?
    var presentVal = 0
    var showDate = ""
    var bookingTime = ""
    var notifyTime : Date?
    var dateStr : Date?
    var notificationDate : Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblAddress.text = dicBagHanlderDetail["Address"] as? String
        guard let bagSpace = self.dicBagHanlderDetail["BagSpace"] as? String else {
            self.showAlert(strMessage: "Can't get bagsapce. Try again.")
            return
        }
        spaceAvailable = Int(bagSpace)!
        print(self.dicBagHanlderDetail)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound])
        {
            (granted, error) in
        }
        self.getDays()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        notify()
    }
    
    func newNotification() {
        
        let calendar = Calendar.current
        
        let content = UNMutableNotificationContent()
        content.title = "Bagation"
        content.body = "Your booking will expire in 30mins. If you would like to extend, please rebook."
        content.sound = UNNotificationSound.default()
        
        var dateComponents = DateComponents()
        if notificationDate == nil {
            return
        }
        
        let finalDate30 = calendar.date(byAdding: .minute, value: -30, to: notificationDate!)
        dateComponents.hour = finalDate30?.hour
        dateComponents.minute = finalDate30?.minute
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "notification1", content: content, trigger: notificationTrigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
//        let request = UNNotificationRequest(identifier: "TestIdentifier", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("granted: (\(granted)")
        }
        
        return true
    }
    
    func notify()
    {
        let calendar = Calendar.current
        print(days)
        let notification = UNMutableNotificationContent()
        notification.title = "Bagation"
        notification.body = "Your booking will expire in 30mins. If you would like to extend, please rebook."
        var dateComponents = DateComponents()
        if notificationDate == nil {
            return
        }
        let finalDate30 = calendar.date(byAdding: .minute, value: -30, to: notificationDate!)
        dateComponents.hour = finalDate30?.hour
        dateComponents.minute = finalDate30?.minute
        notify45()
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "notification1", content: notification, trigger: notificationTrigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func notify45()
    {
        let calendar = Calendar.current
        print(days)
        let notification = UNMutableNotificationContent()
        notification.title = "Bagation"
        notification.body = "Your booking time is about to expire. If you would like to extend, please rebook."
        var dateComponents = DateComponents()
        let finalDate30 = calendar.date(byAdding: .minute, value: -15, to: notificationDate!)
        dateComponents.hour = finalDate30?.hour
        dateComponents.minute = finalDate30?.minute
        
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "notification2", content: notification, trigger: notificationTrigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func getDays()
    {
        
        //YASHAR

        if let str = dicBagHanlderDetail["AvailabilityDays"] as? String {
            
            arrDays = str.components(separatedBy: ",")
            if arrDays.count == 0 {
                self.showAlert(strMessage: "Please set available days in setting.")
                return
            }
            
        }
        
        for ind in 0..<arrDays.count
        {
            let a = arrDays[ind]
            print(a)
            if a == "1"
            {
                days = days + ",Mon"
            }
            if a == "2"
            {
                days = days + ",Tue"
            }
            if a == "3"
            {
                days = days + ",Wed"
            }
            if a == "4"
            {
                days = days + ",Thu"
            }
            if a == "5"
            {
                days = days + ",Fri"
            }
            if a == "6"
            {
                days = days + ",Sat"
            }
            if a == "7"
            {
                days = days + ",Sun"
            }
            print(days)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackButton (_ id: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func textFieldEditing(sender: UITextField) {
        // 6
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        sender.inputView = datePickerView
        
        if sender == self.txtFrom {
            datePickerView.addTarget(self, action: #selector(self.datePickerValueFromChanged), for: UIControlEvents.valueChanged)
            
        } else {
            datePickerView.addTarget(self, action: #selector(self.datePickerValueToChanged), for: UIControlEvents.valueChanged)
        }
    }
    
    @objc func datePickerValueFromChanged(sender:UIDatePicker) {
        presentVal = 0
        self.startUTCDate = sender.date
        print(self.startUTCDate)
        if self.startUTCDate.compare(Date()) == .orderedAscending {
            self.showAlert(strMessage: "Please select valid date.")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a EEE"
        dateFormatter.timeZone = TimeZone.current
//        if UserDefaults.standard.value(forKey: "avDays") != nil
//        {
//            days = UserDefaults.standard.value(forKey: "avDays") as! String
//        }
       
        let strDate = dateFormatter.string(from: sender.date)
        print(strDate)
        last10 = String(strDate.suffix(3))
        print(last10)
        if last10 == "Mon"
        {
            indValueStart = 1
        }
        else if last10 == "Tue"
        {
            indValueStart = 2
        }
        else if last10 == "Wed"
        {
            indValueStart = 3
        }
        else if last10 == "Thu"
        {
            indValueStart = 4
        }
        else if last10 == "Fri"
        {
            indValueStart = 5
        }
        else if last10 == "Sat"
        {
            indValueStart = 6
        }
        else if last10 == "Sun"
        {
            indValueStart = 7
        }
        print(days)
        if days.contains(last10){
            print("exists")
            if (self.txtTo.text?.count != 0) {
                
                let days = Calendar.current.dateComponents([.hour,.minute,.second], from: self.startUTCDate, to: self.endUTCDate)
                let nb_hours = days.hour
                let nb_minute = days.minute
                let nb_second = days.second
                
                if (nb_hours! >= 0 && nb_minute! >= 0 && nb_second! >= 0) {
                    self.txtFrom.text = strDate
                    
                } else {
                    self.showAlert(strMessage: "Please select valid date.")
                    return
                }
            } else
            {
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: startUTCDate)
                let minutes = calendar.component(.minute, from: startUTCDate)
                let seconds = calendar.component(.second, from: startUTCDate)
                
                print("hours = \(hour):\(minutes):\(seconds)")
                bookingTime = "\(hour):\(minutes):\(seconds)"
                let timeNotification = "\(hour):\(minutes-30):\(seconds)"
                print(timeNotification)
                
                let abc = strDate.components(separatedBy: " ")
                print(abc)
                
                dateFormatter.timeZone = TimeZone.current
                let newDate = dateFormatter.date(from: strDate)
                
                dateStr = calendar.date(bySettingHour: hour, minute: minutes-30, second: seconds, of: newDate!)

                self.txtFrom.text = strDate
            }
            if (self.txtBags.text?.count != 0) {
                self.resetTotalAmount(numberOfBags: self.txtBags.text!)
            }
        }
        else
        {
           // self.showAlert(strMessage: "Booking is not available on your selected day")
        }
        
        let url = "\(Constants.baseURLLocal)\(Constants.getStorageSpace)"
        let customDateFormatter = DateFormatter()
        customDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let newDate = customDateFormatter.string(from: self.startUTCDate)
        let param = ["BagHandlerID": self.dicBagHanlderDetail["BagHandlerID"] ?? "", "StartDate": newDate] as [String : Any]
        
        print(param)
        Utility.showHUD(msg: "Getting Space...")
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default).responseString { response in
            Utility.hideHUD()
            switch response.result {
            case .success(let value):
              
                let bagSpace = Int(self.dicBagHanlderDetail["BagSpace"] as! String)! - (Int(value) ?? 0)
                if bagSpace < 1 {
                    self.showAlert(strMessage: "No space")
                    self.availableSpace.text = "0"
                }else{
                    self.availableSpace.text = String(bagSpace)
                }
                break
                
            case .failure(_):
                break
            }
        }
       
    }
    
    @objc func datePickerValueToChanged(sender:UIDatePicker) {
        presentVal = 0
        self.endUTCDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a EEE"
        dateFormatter.timeZone = TimeZone.current
        
        let strDate = dateFormatter.string(from: sender.date)
        notificationDate = sender.date
        last101 = String(strDate.suffix(3))
        print(last101)
        if last101 == "Mon"
        {
            indValueStop = 1
        }
        else if last101 == "Tue"
        {
            indValueStop = 2
        }
        else if last101 == "Wed"
        {
            indValueStop = 3
        }
        else if last101 == "Thu"
        {
            indValueStop = 4
        }
        else if last101 == "Fri"
        {
            indValueStop = 5
        }
        else if last101 == "Sat"
        {
            indValueStop = 6
        }
        else if last101 == "Sun"
        {
            indValueStop = 7
        }
        if presentVal == 1
        {
            self.txtTo.text = ""
        }
        else if presentVal == 0
        {
            self.txtTo.text = dateFormatter.string(from: sender.date)
        }

    }
    
    func resetTotalAmount (numberOfBags:String) {
        let days = Calendar.current.dateComponents([.hour,.minute,.second], from: self.startUTCDate, to: self.endUTCDate)
        
        var nb_hours = days.hour
        let nb_minute = days.minute
        let nb_second = days.second
        
        let startSecond = Calendar.current.component(.second, from: self.startUTCDate)
        let endSecond = Calendar.current.component(.second, from: self.endUTCDate)
        
        if nb_minute! > 0 {
            nb_hours = nb_hours! + 1;
        } else if nb_minute == 0 && startSecond > endSecond {
            nb_hours = nb_hours! + 1;
        }
        
        var Bags : Int = Int(numberOfBags)!
        Bags = Bags * 4
        
        if (nb_hours! >= 0 && nb_minute! >= 0 && nb_second! >= 0) {
            print(nb_hours ?? "")
            if (nb_hours == 0) {
                self.lblTotal.text = String(format:"$ %d.00",Bags)
            } else {
                nb_hours = nb_hours! * Bags
                //let theStringValue = String(describing: nb_hours)
                self.lblTotal.text = String(format:"$ %d.00", nb_hours!)
            }
        } else {
            self.showAlert(strMessage: "Please select valid date.")
        }
    }
    
    
    @IBAction func btnBookStorage (_ id: Any)
    {
        notify()
        let _startTime = self.dicBagHanlderDetail["StartTime"] as! String
        let _endTime = self.dicBagHanlderDetail["EndTime"] as! String
        if(startUTCDate.compare(endUTCDate) == .orderedDescending){
            self.showAlert(strMessage: "Please select From & To date time correclty.")
            return;
        }
        if indValueStart != nil && indValueStop != nil
        {
            if indValueStart! <=  indValueStop! // 2,5
            {
                let result = Array(arrWeekdays[(indValueStart!-1)...(indValueStop!-1)])
                print(result)
                for element in result
                {
                    print(element)
                    if days.contains(element)
                    {
                        if (self.txtBags.text?.count != 0) {
                            self.resetTotalAmount(numberOfBags: self.txtBags.text!)
                        }
                    }
                    else
                    {
                        presentVal = 1
                        let alert = UIAlertController(title: "Alert!", message: "Please check store operating hours", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .cancel) { (actoin) in
                            
                        }
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                }
                print(presentVal)
                
            }
            else if indValueStart! >= indValueStop! // 5,2
            {
                var arr : [String] = []
                var arr1 : [String] = []
                let finalValue = 7
                let val = finalValue-indValueStart!
                print(val)
                for ind in 0...finalValue
                {
                    print(ind)
                    //                    let val = finalValue-indValueStart!
                    //                    print(val)
                    if (ind >= indValueStart!)
                    {
                        arr = Array(arrWeekdays[(indValueStart!-1)...(finalValue-1)])
                        print(arr)
                    }
                    if (ind <= indValueStop!)
                    {
                        arr1 = Array(arrWeekdays[0...(indValueStop!-1)])
                        print(arr1)
                    }
                }

                let result = arr + arr1
                print(result)
                for element in days
                {
                    print(element)
                    if days.contains(element)
                    {
                        if (self.txtBags.text?.count != 0) {
                            self.resetTotalAmount(numberOfBags: self.txtBags.text!)
                        }
                    }
                    else
                    {
                        presentVal = 1
                        let alert = UIAlertController(title: "Alert!", message: "Please check store operating hours", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .cancel) { (actoin) in
                            
                        }
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                }
                
            }
            
        }
        if(!self.checkIfBetween(aStartTime: _startTime, aEndTime: _endTime)){
            return;
        }
        print(_startTime)
        print(_endTime)
        User.shared.loadUser()
        if (User.shared.imagepath == "") || (User.shared.fullname == "") {
            self.showAlert(strMessage: "Your profile is not completed.")
        } else if (self.txtFrom.text?.trim().isEmpty)!{
            self.showAlert(strMessage: "Please select dropoff date time")
        } else if (self.txtTo.text?.trim().isEmpty)!{
            self.showAlert(strMessage: "Please select pickup date time")
        } else if (txtBags.text?.trim().isEmpty)! {
                txtBags.shake()
        } else if (Int((txtBags.text?.trim())!)! > Int(self.availableSpace.text ?? "0")!) {
            txtBags.shake() 
            self.showAlert(strMessage: "Bag Handler has \(String(describing: self.availableSpace.text)) free space only.")
        } else {
            //self.CallApiForBooking()
            self.stripSetup()
        }
    }
    
    func compareTime(aTime1: Date, aTime2: String) -> ComparisonResult{
        
        let _calendar = Calendar(identifier: .gregorian);
        let _nYear = _calendar.component(.year, from: aTime1)
        let _nMonth = _calendar.component(.month, from: aTime1)
        let _nDay = _calendar.component(.day, from: aTime1)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd hh:mm a EEE"
        
        //formatter.timeZone = TimeZone(abbreviation: "GMT+10")
        let _dateTime2 = formatter.date(from: String(format:"%d/%d/%d %@", _nYear, _nMonth, _nDay, aTime2))
        if let _existTime = _dateTime2 {
            return aTime1.compare(_existTime)
        }
        return .orderedAscending
    }
    
    func checkIfBetween(aStartTime: String, aEndTime:String)-> Bool{
        let calendar = Calendar.current
        
        var startDateTime = getOpenDateTime(time: aStartTime)
        var endDateTime = getCloseDateTime(time: aEndTime)
        
        if getDateTime(time: aStartTime).compare(getDateTime(time: aEndTime)) == .orderedDescending {
            endDateTime = endDateTime.tomorrow!
            startDateTime = startDateTime.yesterday!
        }
        endDateTime = calendar.date(byAdding: .second, value: 59, to: endDateTime)!
        if((startUTCDate.compare(startDateTime) == .orderedDescending || startUTCDate.compare(startDateTime) == .orderedSame))
        {
            if (startUTCDate.compare(endDateTime) == .orderedAscending || startUTCDate.compare(endDateTime) == .orderedSame)
            {
                if (endUTCDate.compare(startDateTime) == .orderedDescending || endUTCDate.compare(startDateTime) == .orderedSame)
                {
                    if (endUTCDate.compare(endDateTime) == .orderedAscending || endUTCDate.compare(endDateTime) == .orderedSame)
                    {
                        return true
                    }
                }
            }
        }
        
        //self.showAlert(strMessage: "You can only book between \(aStartTime) and \(aEndTime).")
        self.showAlert(strMessage: "please select valid time/date and check the store operating schedule.")
        return false;
    }
    
    func getTime(time: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.date(from: time)!
    }
    
    func getDateTime(time: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let todayDate = formatter.string(from: Date())
        let date = todayDate + " " + time
        formatter.dateFormat = "yyyy/MM/dd hh:mm a"
        return formatter.date(from: date)!
    }
    
    func getOpenDateTime(time: String) -> Date {
        let formatter = DateFormatter()
        //formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy/MM/dd"
        let startDate = formatter.string(from: self.startUTCDate)
        let openDate = startDate + " " + time
        formatter.dateFormat = "yyyy/MM/dd hh:mm a"
        return formatter.date(from: openDate)!
    }
    
    func getCloseDateTime(time: String) -> Date {
        let formatter = DateFormatter()
        //formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy/MM/dd"
        let endDate = formatter.string(from: self.endUTCDate)
        let closeDate = endDate + " " + time
        formatter.dateFormat = "yyyy/MM/dd hh:mm a"
        return formatter.date(from: closeDate)!
    }
    
    func CallApiForClientNonce() {
        Utility.showHUD(msg: "")
        
        var strTotal = self.lblTotal.text ?? ""
        strTotal = strTotal.replacingOccurrences(of: "$ ", with: "")
        
        let value : Dictionary<String,Any>  = ["strNounce": self.clientNonce , "strAmount": strTotal,"UserID":User.shared.userId,"BagHandlerID":self.dicBagHanlderDetail["BagHandlerID"] ?? "","OrderID":self.orderId ]
        
        print (value)
        
        let url:String = "\(Constants.baseURLLocal)\(Constants.requestClientNonce)"
        print(url)
        Alamofire.request(url, method: .get, parameters: value, encoding: URLEncoding.default).responseString { response in
            Utility.hideHUD()
            switch response.result {
            case .success(_):
                let alert = UIAlertController(title: "Information", message: "You have successfully booked a place for your bags.", preferredStyle: UIAlertControllerStyle.alert)
                
                let action = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                    _ = self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(action)
                self.present(alert, animated:true, completion: nil)
                
                break
                
            case .failure(_):
                self.showAlert(strMessage: "There's a problem with your purchase.")
                break
            }
        }
    }
    
    func CallApiForBooking(){
        
        User.shared.loadUser()
        let objUser = User.shared
        if (objUser.userId.count == 0) {
            let strId = UserDefaults.standard.object(forKey: Constants.key_UserID) 
            objUser.userId = strId as! String
        }
        
        if (objUser.userId.count == 0) {
            let alert = UIAlertController(title: "Alert!", message: "Session expired. Please Sign In again.", preferredStyle: UIAlertControllerStyle.alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                AppDelegate.objAppDelegate.signOut()
            }
            alert.addAction(action)
            self.present(alert, animated:true, completion: nil)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss a"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let newDate = dateFormatter.string(from: self.startUTCDate)
            let newToDate = dateFormatter.string(from: self.endUTCDate)
            
            print(newDate) //New formatted Date string
            Utility.showHUD(msg: "")
            var strTotal = self.lblTotal.text ?? ""
            strTotal = strTotal.replacingOccurrences(of: "$ ", with: "")
            
            let value : Dictionary<String,Any>  = ["UserID": objUser.userId , "BagHandlerID": self.dicBagHanlderDetail["BagHandlerID"] ?? "", "StartDate":newDate ,"EndDate":newToDate ,"Price":"4","NoOfBags":self.txtBags.text!,"TotalAmount":strTotal,"BrainTreeToken":"","PaymentStatus":"1"]
            
            print (value)
            APIManager.getRequestWith(strURL: Constants.requestPlaceOrder, Param: value) { (Dict, Error) in
                Utility.hideHUD()
                if Error == nil {
                    if let value = Dict {
                        print(value)
                        if (value.object(forKey: "code") as! Int == 101) {
                            self.showAlert(strMessage: "Storage space is not available for selected dates.")
                        } else {
                            if (value.object(forKey: "OrderID") != nil) {
                                self.orderId = value.object(forKey: "OrderID") as! String
                            }
                            
                            self.CallApiForClientNonce()
                            //self.stripSetup()
                        }
                    } else {
                        self.showAlert(strMessage: "")
                    }
                } else {
                    self.showAlert(strMessage: "")
                }
            }
        }
        
    }
    
    // MARK: - UITextField
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtFrom {
            //  TODO
//            self.startUTCDate = sender.date
//            print(self.startUTCDate)
//            if self.startUTCDate.compare(Date()) == .orderedAscending {
//                self.showAlert(strMessage: "Please select valid date.")
//                return
//            }
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (self.txtTo.text?.trim().isEmpty)! || (self.txtFrom.text?.trim().isEmpty)! {
            self.showAlert(strMessage: "Please select valid dates.")
            return false
        }
        
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        print(newString)
        
        if (newString.count != 0) {
            if (textField == self.txtBags) && (newString.count != 0){
                
                let days = Calendar.current.dateComponents([.hour,.minute,.second], from: self.startUTCDate, to: self.endUTCDate)
                
                var nb_hours = days.hour
                let nb_minute = days.minute
                let nb_second = days.second
                
                let startSecond = Calendar.current.component(.second, from: self.startUTCDate)
                let endSecond = Calendar.current.component(.second, from: self.endUTCDate)
                
                if nb_minute! > 0 {
                    nb_hours = nb_hours! + 1;
                } else if nb_minute == 0 && startSecond > endSecond {
                    nb_hours = nb_hours! + 1;
                }
                
                var numberOfBags : Int = Int(newString)!
                numberOfBags = numberOfBags * 4
                
                if (nb_hours! >= 0 && nb_minute! >= 0 && nb_second! >= 0) {
                    print(nb_hours ?? "")
                    if (nb_hours == 0) {
                        self.lblTotal.text = String(format:"$ %d.00",numberOfBags)
                    } else {
                        nb_hours = nb_hours! * numberOfBags
                        //let theStringValue = String(describing: nb_hours)
                        self.lblTotal.text = String(format:"$ %d.00",nb_hours!)
                    }
                    // self.CallApiForBooking()
                } else {
                    self.showAlert(strMessage: "Please select valid date.")
                    return false
                }
            }
            
        } else {
            self.lblTotal.text = String(format:"$ %d.00",0)
        }
        
        
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
   
    func stripSetup(){
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        
        let lbl = UILabel()
        lbl.text = "  Payment is powerd and protected by Stripe"
        lbl.font = UIFont(name: "Helvetica Neue Light" , size: 12)
        lbl.sizeToFit()
        lbl.adjustsFontSizeToFitWidth = true
        let width = lbl.intrinsicContentSize.width
        lbl.frame = CGRect(x: 17, y: addCardViewController.view.height - 100, width: width, height: 21)
        
        lbl.textColor = UIColor.gray
        addCardViewController.customFooterView = lbl
        lbl.sizeToFit()
        
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
        //self.showDropIn(clientTokenOrTokenizationKey:self.clientToken)
    }
    
    // MARK: STPAddCardViewControllerDelegate
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        // Dismiss add card view controller
        dismiss(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        print(token)
        self.clientNonce = token.tokenId
        self.CallApiForBooking()
        //self.CallApiForClientNonce()
        dismiss(animated: true)
    }
}

extension Date {
    var tomorrow: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
    
    var yesterday: Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
}
