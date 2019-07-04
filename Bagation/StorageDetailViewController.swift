//
//  StorageDetailViewController.swift
//  Bagation
//
//  Created by Ankur sharma on 01/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit

class StorageDetailViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtEndDate: UITextField!
    @IBOutlet weak var lblNoOfBags: UILabel!
    @IBOutlet weak var lblAmountPaid: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    var arrData = [String : Any]()
    var orderID : Int?
    var strDate = ""
    var endDate = ""
    var activeTextField = UITextField()
    let datePicker = UIDatePicker()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print(arrData)
        txtStartDate.isEnabled = false
        txtEndDate.isEnabled = false
        btnSave.isHidden = true
        orderID = arrData["OrderID"]! as? Int
        let start = arrData["StartDate"]! as? String
        strDate = self.convertDateToFormattedString(string: start!)
        let end = arrData["EndDate"]! as? String
        endDate = self.convertDateToFormattedString(string: end!)
        let bags = arrData["NoOfBags"]! as? Int
        //let amount = arrData["TotalAmount"]! as? String
        lblStoreName.text = arrData["StoreName"] as? String
        lblAddress.text = arrData["Address"] as? String
        txtStartDate.text = strDate
        txtEndDate.text = endDate
        lblNoOfBags.text = "Total Bags: " + "\(String(describing: bags!))"
        lblAmountPaid.text = "Amount paid: " + (arrData["TotalAmount"]! as? String)!
        txtStartDate.delegate = self
        txtEndDate.delegate = self
    }

    func convertDateToFormattedString (string: String) -> String
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //Current time zone
        let date = dateFormatter.date(from: string) //according to date format your date string
//        let dateEnd = dateFormatter.date(from: endDate) //according to date format your date
        
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a EEE" //Your New Date format as per requirement change it own
        //dateFormatter.dateStyle = DateFormatter.Style.medium
        //dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = TimeZone.current
        let newDate = dateFormatter.string(from: date!) //pass Date here
//        let newDateEnd = dateFormatter.string(from: dateEnd!) //pass Date here
        let str = newDate
        return str
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.activeTextField = textField
        
        if activeTextField == txtStartDate || activeTextField == txtEndDate
        {
            self.showDatePicker()
        }
    }
    
    func showDatePicker()
    {
        //Formate Date
        if activeTextField == txtStartDate
        {
            datePicker.minimumDate = NSDate() as Date
            datePicker.datePickerMode = UIDatePickerMode.dateAndTime
            //ToolBar
            let toolbar = UIToolbar();
            toolbar.sizeToFit()
            //done button & cancel button
            let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.donedatePicker))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancelDatePicker))
            toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
            // add toolbar to textField
            txtStartDate.inputAccessoryView = toolbar
            // add datepicker to textField
            txtStartDate.inputView = datePicker
        }
        else if activeTextField == txtEndDate
        {
            datePicker.minimumDate = NSDate() as Date
            datePicker.datePickerMode = UIDatePickerMode.dateAndTime
            //ToolBar
            let toolbar = UIToolbar();
            toolbar.sizeToFit()
            //done button & cancel button
            let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.donedatePicker))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancelDatePicker))
            toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
            // add toolbar to textField
            txtEndDate.inputAccessoryView = toolbar
            // add datepicker to textField
            txtEndDate.inputView = datePicker
        }
    }
    
    @objc func donedatePicker()
    {
        //For date formate
        if activeTextField == txtStartDate
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy hh:mm:ss a"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            txtStartDate.text = formatter.string(from: datePicker.date)
            //dismiss date picker dialog
            self.view.endEditing(true)
        }
        else if activeTextField == txtEndDate
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy hh:mm:ss a"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            txtEndDate.text = formatter.string(from: datePicker.date)
            //dismiss date picker dialog
            self.view.endEditing(true)
        }
    }
    
    @objc func cancelDatePicker()
    {
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }
    
    @IBAction func btnEdit(_ sender: UIButton)
    {
        txtStartDate.isEnabled = true
        txtEndDate.isEnabled = true
        btnSave.isHidden = false
        lblAddress.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
        lblNoOfBags.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
        lblAmountPaid.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    }
    
    @IBAction func btnDelete(_ sender: UIButton)
    {
        APIManager.deleteBooking(OrderID: orderID!) { (response) in
            print(response)
            
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Savebtn(_ sender: UIButton)
    {
        let str = txtStartDate.text?.replacingOccurrences(of: " ", with: "%20")
        let end = txtEndDate.text?.replacingOccurrences(of: " ", with: "%20")
        APIManager.editBooking(OrderID: orderID!, StartDate: str!, EndDate: end!) { (response) in
            print(response)
            
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    


}
