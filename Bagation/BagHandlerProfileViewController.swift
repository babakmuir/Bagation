//
//  BagHandlerProfileViewController.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import GooglePlacePicker
import CoreLocation
import Photos
class BagHandlerProfileViewController: UIViewController,SideMenuItemContent,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet weak var txtName                          : UITextField!
    @IBOutlet weak var txtEmail                         : UITextField!
    @IBOutlet weak var txtPhoneNo                       : UITextField!
    @IBOutlet weak var btnImageProfile                  : UIButton!
    @IBOutlet weak var txtStoreDecription               : UITextField! //Using as ABN Field
    @IBOutlet weak var txtSpaceAvailable                : UITextField!
    @IBOutlet weak var txtLocation                       : UITextField!
    @IBOutlet weak var txtStoreName                       : UITextField!
    @IBOutlet weak var txtStartTime                       : UITextField!
    @IBOutlet weak var txtEndTime                        : UITextField!
    @IBOutlet weak var txtAvailable: UITextField!
    @IBOutlet weak var btnMon: UIButton!
    @IBOutlet weak var btnTue: UIButton!
    @IBOutlet weak var btnWed: UIButton!
    @IBOutlet weak var btnThurs: UIButton!
    @IBOutlet weak var btnFri: UIButton!
    @IBOutlet weak var btnSat: UIButton!
    @IBOutlet weak var btnSun: UIButton!
    @IBOutlet weak var viewDays: UIView!
    @IBOutlet weak var selectDaysButton: UIButton!
    var isMonCheck : Bool?
    var isTueCheck : Bool?
    var isWedCheck : Bool?
    var isThursCheck : Bool?
    var isFriCheck : Bool?
    var isSatCheck : Bool?
    var isSunCheck : Bool?
    var selectedPlace:GMSPlace!
    var city:String! = ""
    var state:String! = ""
    var days = ""
    var arrDays : [String] = []
    var strLat:String! = ""
    var strLong:String! = ""
    var onlineStatus = ""
    var bagHandlerID : Int?
    //var arrDays : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDays.isHidden = true
        mySwitch.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
        selectDaysButton.addTarget(self, action: #selector(selectDaysButtonAction(sender:)), for: .touchUpInside)
        switchLabel.text = "Status:"
        
        checkPermission()
        if UserDefaults.standard.value(forKey: "days") != nil
        {
            guard let day = UserDefaults.standard.value(forKey: "days") as? String else {
                return
            }
            arrDays = day.components(separatedBy: ",")
        }
        CallApiForLogin()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func updatePasswordButton(_ sender: Any) {
        
        if (txtEmail.text!.isEmpty || txtName.text!.isEmpty || txtPhoneNo.text!.isEmpty) {
            
            showAlert(strMessage: "Please fill empty text fields.")
            
        } else {
            
            performSegue(withIdentifier: "baghandlerToUpdatePassword", sender: self)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "baghandlerToUpdatePassword" {
            
            let destination = segue.destination as! UpdatePasswordViewController
            
            destination.emailText = txtEmail.text!
            
            destination.fullName = txtName.text!
            
            destination.phoneNumber = txtPhoneNo.text!
            
        }
        
    }
    
    
    @objc func selectDaysButtonAction(sender: UIButton) {
        print("button tapped")
        if viewDays.isHidden == true
        {
            viewDays.isHidden = false
        }
        else
        {
            viewDays.isHidden = true
        }
    }
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let strId = UserDefaults.standard.object(forKey: Constants.key_UserID) as? String
        if let _ = strId  {
            bagHandlerID = Int(strId!)
        }
        configureNavigation()
        let img = #imageLiteral(resourceName: "icon-menu")
        if let parent = self.parent {
            let btnback = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.openMenuAction))
            parent.navigationItem.leftBarButtonItem = btnback
            parent.title = "Update Profile"
        }
        setAvailability()
    }
    
    func setAvailability()
    {
        for ind in 0..<arrDays.count
        {
            let a = arrDays[ind]
            print(a)
            if a == "1"
            {
                days = days + " Mon"
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
                days = days + ",Thurs"
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
        txtAvailable.text = String(days.dropFirst())
        days = ""
    }
    
    func loadProfileData() {
        let userObj = User.shared
        self.txtName.text = userObj.fullname.capitalized(with: NSLocale.current)
        self.txtEmail.text = userObj.email
        self.txtPhoneNo.text = userObj.phoneno
        self.txtStoreDecription.text = userObj.StoreDesc
        self.txtSpaceAvailable.text = userObj.BagSpace
        self.txtStoreName.text = userObj.StoreName
        self.txtLocation.text = userObj.Address
        self.strLat = userObj.latitude
        self.strLong = userObj.longitude
        self.txtStartTime.text = userObj.startTime
        self.txtEndTime.text = userObj.endTime
        
        if Constants.objDefault.value(forKey: Constants.Key_UserProfilePic) != nil {
            User.shared.imagepath = Constants.objDefault.value(forKey: Constants.Key_UserProfilePic) as! String
        }
        
        if (User.shared.imagepath.count != 0) {
            self.btnImageProfile.loadingIndicator(show: true)
            APIManager.downloadImageFrom(strUrl: User.shared.imagepath, callback: { (img) in
                if let image = img{
                    self.btnImageProfile.loadingIndicator(show: false)
                    self.btnImageProfile.contentMode = .scaleAspectFit
                    self.btnImageProfile.setImage(image, for: .normal)
                    self.btnImageProfile.layer.cornerRadius = self.btnImageProfile.frame.size.height/2.0
                    self.btnImageProfile.layer.masksToBounds = true
                }
            })
            
        }
        self.addDoneButtonOnPhoneNoKeyboard()
    }
    @objc func switchChanged(sender: UISwitch!) {
        print("Switch value is \(sender.isOn)")
        
        if sender.isOn == true
        {
            onlineStatus = "1"
      
            switchLabel.text = "Status   ACTIVE:"
            UserDefaults.standard.set(true, forKey: "SwitchState")
            APIManager.checkOnlineStatus(BaghandlerID: bagHandlerID!, IsOnline: Int(onlineStatus)!) { (response) in
                print(response)
           
                
            }
           
        }
        else if sender.isOn == false
        {
            let alert = UIAlertController(title: "BAGATION", message: "Please make sure you have no pending bookings before you turn your store off.", preferredStyle: UIAlertControllerStyle.alert)
            
            let action = UIAlertAction(title: "Turn Off", style: .default) { (alertAction) in
                
              
                self.switchLabel.text = "Status   INACTIVE:"
                UserDefaults.standard.set(false, forKey: "SwitchState")
                self.onlineStatus = "0"
                APIManager.checkOnlineStatus(BaghandlerID: self.bagHandlerID!, IsOnline: Int(self.onlineStatus)!) { (response) in
                    print(response)
                    //self.tableView.reloadData()
                    
                }
               // self.tableView.reloadData()
            }
            let actionNo = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in
                sender.isOn = true
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            alert.addAction(actionNo)
            self.present(alert, animated:true, completion: nil)
        }
        UserDefaults.standard.synchronize()
        
    }
    
    @objc func openMenuAction(){
        showSideMenu()
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        showSideMenu()
    }
    
    @IBAction func btnLocationPicker(_ sender: UIButton) {
        showPicker()
    }
    
    @IBAction func btnUpdateProfie(_ sender: UIButton) {

        self.view.endEditing(true)
        if (txtName.text?.trim().isEmpty)!{
            txtName.shake()
        } else  if(txtEmail.text?.trim().isEmpty)!{
            txtEmail.shake()
        } else if !Utility.isValidEmail(testStr: txtEmail.text!){
            self.showAlert(strMessage: ConstantsMessages.msgValidEmail)
        } else if (txtStoreName.text?.trim().isEmpty)!{
            txtStoreName.shake()
        } else if (txtLocation.text?.trim().isEmpty)!{
            txtLocation.shake()
        } else if (txtLocation.text?.trim().isEmpty)!{
            txtLocation.shake()
        } else  if(txtPhoneNo.text?.trim().isEmpty)!{
            txtPhoneNo.shake()
        } else if (txtSpaceAvailable.text?.trim().isEmpty)!{
            txtSpaceAvailable.shake()
        } else if (txtStartTime.text?.trim().isEmpty)!{
            txtStartTime.shake()
        } else if (txtEndTime.text?.trim().isEmpty)!{
            txtEndTime.shake()
        } else if (txtStoreDecription.text?.trim().isEmpty)!{
            txtStoreDecription.shake()
        } else if ((txtStoreDecription.text?.count)! < 11){
             self.showAlert(strMessage: ConstantsMessages.msgABNInvalid)
        } else {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(txtLocation.text!) {
                placemarks, error in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                    let alert = UIAlertController(title: "Error", message: "Can't get location information. Please re-enter location.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            
                        }))
                    self.present(alert, animated: true, completion: nil)
                    return;

                }
                let placemark = placemarks?.first
                
                let numLat = NSNumber(value: (placemark?.location?.coordinate.latitude)! as Double)
                let stLat:String = numLat.stringValue
                
                let numLon = NSNumber(value: (placemark?.location?.coordinate.longitude)! as Double)
                let stLon:String = numLon.stringValue
                
                self.strLat = stLat
                self.strLong = stLon
                self.CallApiForSignup()
            }
        }
    }
    
    @IBAction func textFieldEditing(sender: UITextField) {
        // 6
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.time
        sender.inputView = datePickerView
        
        if sender == self.txtStartTime {
            datePickerView.addTarget(self, action: #selector(self.datePickerValueFromChanged), for: UIControlEvents.valueChanged)
            
        } else {
            datePickerView.addTarget(self, action: #selector(self.datePickerValueToChanged), for: UIControlEvents.valueChanged)
        }
    }
    func insertElementAtIndex(element: String?, index: Int)
    {
         //arrDays.removeAll()
        while arrDays.count <= index
        {
            arrDays.append("")
        }
        arrDays.insert(element!, at: index)
    }
    @objc func datePickerValueFromChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        let strDate = dateFormatter.string(from: sender.date)
        self.txtStartTime.text = strDate
    }
    
    @objc func datePickerValueToChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.current
       self.txtEndTime.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func btnStartEndTime(_ sender: UIButton) {
        
    }
    
    @IBAction func btnImageProfile(_ sender: UIButton) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Please Select Image", message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "From Library", style: .default)
        { _ in
            self.launchImagePicker()
        }
        actionSheetController.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "From Camera", style: .default)
        { _ in
            self.launchCameraPicker()
        }
        actionSheetController.addAction(deleteActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    @IBAction func btnMondayAct(_ sender: UIButton)
    {
        if btnMon.imageView?.image == #imageLiteral(resourceName: "unchecked(1)")
        {
            btnMon.setImage(#imageLiteral(resourceName: "checked(1)"), for: .normal)
            isMonCheck = true
            insertElementAtIndex(element: "1", index: 0)
            arrDays = arrDays.filter{$0 != ""}
        }
        else if btnMon.imageView?.image == #imageLiteral(resourceName: "checked(1)")
        {
            btnMon.setImage(#imageLiteral(resourceName: "unchecked(1)"), for: .normal)
            isMonCheck = false
            arrDays = arrDays.filter{$0 != "1"}
        }
    }
    
    @IBAction func btnTuesdayAct(_ sender: UIButton)
    {
        if btnTue.imageView?.image == #imageLiteral(resourceName: "unchecked(1)")
        {
            btnTue.setImage(#imageLiteral(resourceName: "checked(1)"), for: .normal)
            isTueCheck = true
            insertElementAtIndex(element: "2", index: 1)
            arrDays = arrDays.filter{$0 != ""}
        }
        else if btnTue.imageView?.image == #imageLiteral(resourceName: "checked(1)")
        {
            btnTue.setImage(#imageLiteral(resourceName: "unchecked(1)"), for: .normal)
            isTueCheck = false
            arrDays = arrDays.filter{$0 != "2"}
        }
    }
    
    @IBAction func btnWedAct(_ sender: UIButton)
    {
        if btnWed.imageView?.image == #imageLiteral(resourceName: "unchecked(1)")
        {
            btnWed.setImage(#imageLiteral(resourceName: "checked(1)"), for: .normal)
            isWedCheck = true
            insertElementAtIndex(element: "3", index: 2)
            arrDays = arrDays.filter{$0 != ""}
        }
        else if btnWed.imageView?.image == #imageLiteral(resourceName: "checked(1)")
        {
            btnWed.setImage(#imageLiteral(resourceName: "unchecked(1)"), for: .normal)
            isWedCheck = false
            arrDays = arrDays.filter{$0 != "3"}
        }
    }
    
    @IBAction func btnThursAct(_ sender: UIButton)
    {
        if btnThurs.imageView?.image == #imageLiteral(resourceName: "unchecked(1)")
        {
            btnThurs.setImage(#imageLiteral(resourceName: "checked(1)"), for: .normal)
            isThursCheck = true
            insertElementAtIndex(element: "4", index: 3)
            arrDays = arrDays.filter{$0 != ""}
        }
        else if btnThurs.imageView?.image == #imageLiteral(resourceName: "checked(1)")
        {
            btnThurs.setImage(#imageLiteral(resourceName: "unchecked(1)"), for: .normal)
            isThursCheck = false
            arrDays = arrDays.filter{$0 != "4"}
        }
    }
    
    @IBAction func btnFridayAct(_ sender: UIButton)
    {
        if btnFri.imageView?.image == #imageLiteral(resourceName: "unchecked(1)")
        {
            btnFri.setImage(#imageLiteral(resourceName: "checked(1)"), for: .normal)
            isFriCheck = true
            insertElementAtIndex(element: "5", index: 4)
            arrDays = arrDays.filter{$0 != ""}
        }
        else if btnFri.imageView?.image == #imageLiteral(resourceName: "checked(1)")
        {
            btnFri.setImage(#imageLiteral(resourceName: "unchecked(1)"), for: .normal)
            isFriCheck = false
            arrDays = arrDays.filter{$0 != "5"}
        }
    }
    
    @IBAction func btnSatAct(_ sender: UIButton)
    {
        if btnSat.imageView?.image == #imageLiteral(resourceName: "unchecked(1)")
        {
            btnSat.setImage(#imageLiteral(resourceName: "checked(1)"), for: .normal)
            isSatCheck = true
            insertElementAtIndex(element: "6", index: 5)
            arrDays = arrDays.filter{$0 != ""}
        }
        else if btnSat.imageView?.image == #imageLiteral(resourceName: "checked(1)")
        {
            btnSat.setImage(#imageLiteral(resourceName: "unchecked(1)"), for: .normal)
            isFriCheck = false
            arrDays = arrDays.filter{$0 != "6"}
        }
    }
    
    @IBAction func btnSundayAct(_ sender: UIButton)
    {
        if btnSun.imageView?.image == #imageLiteral(resourceName: "unchecked(1)")
        {
            btnSun.setImage(#imageLiteral(resourceName: "checked(1)"), for: .normal)
            isSunCheck = true
            insertElementAtIndex(element: "7", index: 6)
            arrDays = arrDays.filter{$0 != ""}
        }
        else if btnSun.imageView?.image == #imageLiteral(resourceName: "checked(1)")
        {
            btnSun.setImage(#imageLiteral(resourceName: "unchecked(1)"), for: .normal)
            isSunCheck = false
            arrDays = arrDays.filter{$0 != "7"}
        }
    }
    
    @IBAction func btnSave(_ sender: UIButton)
    {
        print(arrDays)
        txtAvailable.text = ""
        let weekDayNumbers = [
            "1": 1,
            "2": 2,
            "3": 3,
            "4": 4,
            "5": 5,
            "6": 6,
            "7": 7
        ]
        arrDays.sort(by: { (weekDayNumbers[$0] ?? 7) < (weekDayNumbers[$1] ?? 7) })
        print(arrDays)
        UserDefaults.standard.set(arrDays.joined(separator: ","), forKey: "days")
        UserDefaults.standard.synchronize()
        let stringRepresentation = (arrDays.map{String($0)}).joined(separator: ",")
        print(stringRepresentation)
        APIManager.setAvailability(BaghandlerID: bagHandlerID!, availability: stringRepresentation) { (response) in
            print(response)
        }
        setAvailability()
        viewDays.isHidden = true
    }
    
    @IBAction func btnCancel(_ sender: UIButton)
    {
        viewDays.isHidden = true
    }
    func launchImagePicker(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func launchCameraPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let compressedImage = UIImage(data: UIImageJPEGRepresentation(chosenImage, 0.70)!)!
        // use the image
        btnImageProfile.setImage(chosenImage, for: .normal)
        btnImageProfile.layer.cornerRadius =  self.btnImageProfile.frame.size.height/2.0
        btnImageProfile.layer.masksToBounds = true
        btnImageProfile.layer.borderWidth = 2.0
        btnImageProfile.layer.borderColor = UIColor.white.cgColor
        btnImageProfile.imageView?.contentMode = .scaleAspectFit
        self.dismiss(animated: true, completion: nil)
        self.uploadProfilePic(Image: compressedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func showPicker()
    {
        self.view.endEditing(true)
        var center = CLLocationCoordinate2DMake(AppDelegate.objAppDelegate.currentLat, AppDelegate.objAppDelegate.currentLong)
        User.shared.loadUser()
        let user = User.shared
        if !user.latitude.isEmpty && !user.longitude.isEmpty {
            let lat = (user.latitude as NSString).doubleValue
            let lon = (user.longitude as NSString).doubleValue
            center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let  placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    
    // MARK: - UItextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if txtName == textField{
            txtEmail.becomeFirstResponder()
        } else if txtEmail == textField{
            txtStoreName.becomeFirstResponder()
        } else if txtStoreName == textField{
            txtLocation.becomeFirstResponder()
        }else if txtLocation == textField{
            txtStoreDecription.becomeFirstResponder()
        }else if txtStoreDecription == textField{
            txtPhoneNo.becomeFirstResponder()
        }else if txtPhoneNo == textField{
            txtSpaceAvailable.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func addDoneButtonOnPhoneNoKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.txtPhoneNo.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.txtPhoneNo.resignFirstResponder()
    }
    
    // MARK: - API For Signup
    func CallApiForSignup(){
        Utility.showHUD(msg: "")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.txtLocation.text!) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            
            self.strLat = lat?.toString()
            self.strLong = lon?.toString()
            
           // print("Lat: \(lat), Lon: \(lon)")
        }
        
        if Constants.objDefault.value(forKey: Constants.Key_DeviceToken) == nil {
            Constants.objDefault.set("", forKey: Constants.Key_DeviceToken)
        }
        
        let strToken:String = Constants.objDefault.value(forKey: Constants.Key_DeviceToken) as! String
        
        var param =  [String: Any]()
        let objUser = User.shared
        
        if (objUser.userId.count == 0) {
            let alert = UIAlertController(title: "Alert!", message: "Session expired. Please Sign In again.", preferredStyle: UIAlertControllerStyle.alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                AppDelegate.objAppDelegate.signOut()
            }
            alert.addAction(action)
            self.present(alert, animated:true, completion: nil)
        } else {
            
        if (self.strLat.count == 0) {
            self.strLat = objUser.latitude
            self.strLong = objUser.longitude
        }
            
            
        //logintype=1 1=register and 2=fb
        //DeviceType = 1 1=ios and 2= android
        //UserTypes=1 , 1=traveller and 2=baghandler
        
            param = ["email":txtEmail.text!,"password":objUser.password,"DeviceType":"1","fullname":txtName.text!,"phoneno":txtPhoneNo.text ?? "","fbid":objUser.fbId,"logintype":"1","deviceToken":strToken,"gender":"1","UserTypes":"2","UserID":objUser.userId,"StoreDesc":txtStoreDecription.text!,"BagSpace":txtSpaceAvailable.text!,"StoreName":txtStoreName.text!,"Address":self.txtLocation.text!,"Latitude":self.strLat! ,"Longitude":self.strLong!,"StartTime":txtStartTime.text!,"EndTime":txtEndTime.text!] as [String : Any]
        
        print(param)
        
        APIManager.getRequestWith(strURL: Constants.requestAPISignUP, Param: param) { (Dict, Error) in
            Utility.hideHUD()
            if Error == nil{
                if let value = Dict{
                    print(value)
                    if ((value.object(forKey: "code")) as! Int == 100) {
                        //Full Name, Email,  Store Name, Location, Description (Optional), Contact No, Space Available.

                        var valueToStore =  [String: Any]()
                        let objUser = User.shared
                        //valueToStore = ["email":self.txtEmail.text!,"password":objUser.password,"fullname":self.txtName.text!,"fbid":objUser.fbId,"deviceToken":strToken,"imagepath":objUser.imagepath,"userId":objUser.userId,"UserTypes":"2","phoneno":self.txtPhoneNo.text ?? "","StoreDesc":self.txtStoreDecription.text ?? "","BagSpace":self.txtSpaceAvailable.text ?? "","StoreName":self.txtStoreName.text ?? "","Address":self.txtLocation.text ?? ""] as [String : Any]
                        valueToStore = ["userId":objUser.userId, "email":self.txtEmail.text!, "password":objUser.password, "deviceToken":strToken, "fullname":self.txtName.text!, "latitude":self.strLat, "longitude":self.strLong, "imagepath":objUser.imagepath, "phoneno":self.txtPhoneNo.text ?? "", "fbid":objUser.fbId, "userType":"2", "StoreDesc":self.txtStoreDecription.text ?? "", "BagSpace":self.txtSpaceAvailable.text ?? "", "StoreName":self.txtStoreName.text ?? "", "Address":self.txtLocation.text ?? "", "StartTime":self.txtStartTime.text ?? "","EndTime":self.txtEndTime.text ?? ""] as [String : Any]
                        
                        let user = User.init(dic: valueToStore)
                        User.shared.saveUser(user: user)
                        FireBaseManager.sharedInstance.insertUserImage()
                        self.showAlert(strMessage: "You have successfully updated your profile.")
                    } else {
                        self.showAlert(strMessage: (value.object(forKey: "Message")) as! String)
                    }
                }
            }
            }
            
        }
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
                            
                            self.loadProfileData()
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
    
    func uploadProfilePic(Image:UIImage){
        self.btnImageProfile.loadingIndicator(show: true)
        APIManager.uploadImageWith(img: Image) { (dict, error) in
            self.btnImageProfile.loadingIndicator(show: false)
            if (dict != nil) {
                if let value = (dict!["UploadProfilePhotoNewResult"] as! [String:Any])["ProfilePhoto"] {
                    let strValue:String = value as! String
                    UserDefaults.standard.set(strValue, forKey: Constants.Key_UserProfilePic)
                    User.shared.loadUser()
                    let user = User.shared
                    user.imagepath = strValue
                    User.shared.saveUser(user: user)
                }
            }
        }
    }

}

extension Double {
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}

extension BagHandlerProfileViewController:GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        self.strLat =  String(format: "%f", place.coordinate.latitude)
        self.strLong = String(format: "%f", place.coordinate.longitude)
        
        User.shared.loadUser()
        let user = User.shared
        user.latitude = self.strLat
        user.longitude = self.strLong
        User.shared.saveUser(user: user)
        
        selectedPlace  = place
        let address =   place.formattedAddress
        let addressComponents = selectedPlace?.addressComponents
        
        if addressComponents != nil {
            for component in addressComponents! {
                if component.type == "city" {
                    self.city = component.name
                }
                if component.type == "state" {
                    self.state = component.name
                }
            }
        }
        
        txtLocation.text = address
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        print("No place selected")
    }
}

