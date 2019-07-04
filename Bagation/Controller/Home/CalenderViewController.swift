//
//  CalenderViewController.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import FSCalendar
import CalendarKit
import DateToolsSwift
import EventKit

class CalenderViewController: UIViewController {

    @IBOutlet weak var calenderView: FSCalendar!
    @IBOutlet weak var tblEvent: UITableView!
    
    var selectedDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func gotoEventsView(){
        let obj =  EventsViewController()
        obj.currentDate = self.selectedDate
        self.navigationController?.pushViewController(obj, animated: true)
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
        
    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
       
    }
    
}
