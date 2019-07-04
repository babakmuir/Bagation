//
//  EventsViewController.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import Foundation
import UIKit

enum SelectedStyle {
    case Dark
    case Light
}

class EventsViewController: DayViewController {
    
    var currentStyle = SelectedStyle.Light
    
    var colors = [Constants.eventColor1]
    var data = [["Breakfast at Tiffany's",
                 "New York, 5th avenue"],
                
                ["Workout",
                 "Tufteparken"],
                
                ["Meeting with Alex",
                 "Home",
                 "Oslo, Tjuvholmen"],
                
                ["Beach Volleyball",
                 "Ipanema Beach",
                 "Rio De Janeiro"],
                
                ["WWDC",
                 "Moscone West Convention Center",
                 "747 Howard St"],
                
                ["Google I/O",
                 "Shoreline Amphitheatre",
                 "One Amphitheatre Parkway"],
                
                ["✈️️ to Svalbard ❄️️❄️️❄️️❤️️",
                 "Oslo Gardermoen"],
                
                ["💻📲 Developing CalendarKit",
                 "🌍 Worldwide"],
                
                ["Software Development Lecture",
                 "Mikpoli MB310",
                 "Craig Federighi"],
                
                ]
    var currentDate:Date?
    var arrayEvents = [EventDAO]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayout()
        configureNavigationWithTitle()
        let btn2 = UIButton(type: .custom)
        btn2.contentMode = .scaleAspectFill
        btn2.setImage(UIImage(named: "chat"), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        btn2.addTarget(self, action: #selector(self.openChatAction), for: .touchUpInside)
        let btnChat = UIBarButtonItem(customView: btn2)
        navigationItem.rightBarButtonItem = btnChat
        getUserStoragHistory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func prepareLayout(){
        if let date = currentDate {
            dayView.state?.move(to: date)
        }
        dayView.autoScrollToFirstEvent = true
    }
    
    @objc func openChatAction(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let obj:ChatViewController = storyboard.instantiateViewController(withIdentifier: "chatView") as! ChatViewController
        obj.strNav = "YES"
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    func getUserStoragHistory(){
        //2018-11-08
        Utility.showHUD(msg: "")
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let now = dateformatter.string(from: currentDate!)
        print(now)
        let end = currentDate?.endOfWeek
        let endDate = dateformatter.string(from: end!)
        print(endDate)
        let  param = ["UserID":User.shared.userId,"StartDate":now,"EndDate":endDate] as [String : Any]
        print(param)
        print(Date().startOfWeek)
        print(Date().endOfWeek)
        APIManager.getRequestWith(strURL: Constants.requestAPICalender, Param: param) { (Dict, Error) in
            Utility.hideHUD()
            if Error == nil {
                self.arrayEvents = []
                if let data = Dict!["GetAllOrderDetailsByBagHandlerIDResult"] {
                    let array:[Any] = data as! [Any]
                    print(array)
                    self.arrayEvents.removeAll()
                    for obj in array {
                        let dic = obj as! NSDictionary
                        if (dic.value(forKey: "IsReleased") as! String == "0") {
                            let event = EventDAO(eventDict: obj as! [String : Any])
                            self.arrayEvents.append(event)
                        }
                    }
                    if let date = self.currentDate {
                        self.dayView.autoScrollToFirstEvent = true
                        DispatchQueue.main.async { [weak self] in
                            self!.dayView.state?.move(to: date)
                            self!.dayView.reloadData()
                            self!.dayView.reloadInputViews()
                        
                        }
                     
                    }
                    
                }
            }
            self.dayView.reloadData()
            self.dayView.reloadInputViews()
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // MARK: EventDataSource
     override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        
     var events = [Event]()
     print(self.arrayEvents.count)
        for obj in self.arrayEvents {
            let event = Event()
            var duration:Int =  self.getHour(date: obj.StartDate!)
            print(duration)
            let value = obj.StartDate?.offset(from: obj.EndDate!)
            //print(value)
            
            var datePeriod = TimePeriod(beginning: obj.StartDate!, end: obj.EndDate!)
           /* var  datePeriod = TimePeriod(beginning: obj.StartDate!,
                                          chunk: TimeChunk.dateComponents(hours: duration))*/
            if let number = Int((value?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!) {
                // Do something with this number
                duration = number
            }
            if (value?.contains("y"))! {
                datePeriod = TimePeriod(beginning: obj.StartDate!,
                                        chunk: TimeChunk.dateComponents(years: duration))
            }else if (value?.contains("M"))! {
                datePeriod = TimePeriod(beginning: obj.StartDate!,
                                        chunk: TimeChunk.dateComponents(months: duration))
            }else if (value?.contains("w"))! {
                datePeriod = TimePeriod(beginning: obj.StartDate!,
                                        chunk: TimeChunk.dateComponents(weeks: duration))
            }else if (value?.contains("d"))! {
                datePeriod = TimePeriod(beginning: obj.StartDate!,
                                        chunk: TimeChunk.dateComponents(days: duration))
            }else if (value?.contains("h"))! {
                datePeriod = TimePeriod(beginning: obj.StartDate!,
                                        chunk: TimeChunk.dateComponents(hours: duration))
            }
            else if (value?.contains("m"))! {
                datePeriod = TimePeriod(beginning: obj.StartDate!,
                                        chunk: TimeChunk.dateComponents(minutes: duration))
            }
            
            let info = ["name":obj.DisplayName!,"firebase_id":obj.FirBaseID!]
           event.userInfo = info
           event.datePeriod = datePeriod
           
            event.text = "\(obj.DisplayName!)\n" + "Bags:\(obj.NoOfBags!)\n" + "Amount:$\(obj.TotalAmount!)\n"  + "\(datePeriod.beginning!.format(with: "dd.MM.YYYY")) \n" + "\(self.convertTime(date: obj.StartDate!)) - \(self.convertTime(date: obj.EndDate!))"
                 event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
            
                 // Event styles are updated independently from CalendarStyle
                 // hence the need to specify exact colors in case of Dark style
                 if currentStyle == .Dark {
                 event.textColor = textColorForEventInDarkTheme(baseColor: event.color)
                 event.backgroundColor = event.color.withAlphaComponent(0.6)
                 }
            events.append(event)

        }
/*
 for i in 0..<self.arrayEvents.count {
     let event = Event()
     let duration = Int(arc4random_uniform(160) + 60)
     let datePeriod = TimePeriod(beginning: date,
     chunk: TimeChunk.dateComponents(minutes: duration))

     event.datePeriod = datePeriod
     var info = data[Int(arc4random_uniform(UInt32(data.count)))]
     info.append("\(datePeriod.beginning!.format(with: "dd.MM.YYYY"))")
     info.append("\(datePeriod.beginning!.format(with: "HH:mm")) - \(datePeriod.end!.format(with: "HH:mm"))")
     event.text = info.reduce("", {$0 + $1 + "\n"})
     event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]

     // Event styles are updated independently from CalendarStyle
     // hence the need to specify exact colors in case of Dark style
     if currentStyle == .Dark {
     event.textColor = textColorForEventInDarkTheme(baseColor: event.color)
     event.backgroundColor = event.color.withAlphaComponent(0.6)
     }
*/

//     let nextOffset = Int(arc4random_uniform(250) + 40)
//     let  date = date.add(TimeChunk.dateComponents(minutes: nextOffset))
   //  }
     
     return events
     }
    
    func convertTime(date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func getHour(date:Date) -> Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        return Int(dateString)!
    }
    
    private func textColorForEventInDarkTheme(baseColor: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s * 0.3, brightness: b, alpha: a)
    }
    
    // MARK: DayViewDelegate
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? Event else {
            return
        }
        print("Event has been selected: \(descriptor) \(String(describing: descriptor.userInfo))")
        if descriptor.userInfo != nil {
            let store = StorageDAO(storageDict: [:])
            if let name = (descriptor.userInfo as! [String:Any])["name"] {
                store.DisplayName = name as? String
            }
            if let name = (descriptor.userInfo as! [String:Any])["firebase_id"] {
                store.FirBaseID = name as? String
            }
            if let name = (descriptor.userInfo as! [String:Any])["deviceToken"] {
                store.FirebaseReceiverDeviceToken = name as? String
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let obj:ConversationViewController = storyboard.instantiateViewController(withIdentifier: "conversationView") as! ConversationViewController
            obj.objUser = store
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? Event else {
            return
        }
        print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
    }
    
    override func dayView(dayView: DayView, willMoveTo date: Date) {
        //    print("DayView = \(dayView) will move to: \(date)")
    }
    
    override func dayView(dayView: DayView, didMoveTo date: Date) {
           print("DayView = \(dayView) did move to: \(date)")
        self.currentDate = date
       // self.getUserStoragHistory()
    }
    
}
