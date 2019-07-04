//
//  BagHandlerSignupViewController.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import GooglePlacePicker
import InteractiveSideMenu

class BagHandlerSignupViewController: UITableViewController,SideMenuItemContent,UIGestureRecognizerDelegate {

    @IBOutlet weak var txtName                          : UITextField!
    @IBOutlet weak var txtEmail                         : UITextField!
    @IBOutlet weak var txtStoreName                     : UITextField!
    @IBOutlet weak var txtStoreAddress                  : UITextField!
    @IBOutlet weak var txtStoreDecription               : UITextField!
    @IBOutlet weak var txtPassword                      : UITextField!
    @IBOutlet weak var txtConfirmPassword               : UITextField!
    @IBOutlet weak var btnSignup                        : UIButton!
    @IBOutlet weak var lblPassLabel                     : UILabel!
    @IBOutlet weak var lblConfirmPassLabel              : UILabel!
    @IBOutlet var btnMenu                               : UIButton!
    @IBOutlet weak var txtTermsService               : UITextView!
    @IBOutlet var sideMenuCell                          :[UITableViewCell]!
    @IBOutlet var signupCell                            :[UITableViewCell]!

    var appMode: String! = ""
    
    var fbUserData : NSDictionary = [:]
    
    var selectedPlace:GMSPlace!
    var city:String! = ""
    var state:String! = ""
    
    var strLat:String! = ""
    var strLong:String! = ""
    
    var isFromSignup:String?
    var tapTerm:UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (fbUserData.count != 0) {
            self.prepareFBUserProfile()
        }
        tapTerm = UITapGestureRecognizer(target: self, action: #selector(self.myviewTapped(_:)))
        tapTerm.delegate = self
        tapTerm.numberOfTapsRequired = 1
        tapTerm.numberOfTouchesRequired = 1
        txtTermsService.addGestureRecognizer(tapTerm)
        txtTermsService.isUserInteractionEnabled = true
    }
    
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        print("tapped term – but blocking the tap for textView :-/")
        let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let termsViewController = storyBoard.instantiateViewController(withIdentifier: "termsServices") as! TermsServicesViewController
        termsViewController.comingFor = "2"
        self.present(termsViewController, animated: true, completion: nil)
        
    }
    
    
    //MARK - Gesture recognizer delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromSignup != nil {
            self.tableView.reloadData()
        }
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFromSignup != nil {
            //68,184,225
            self.tableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func prepareFBUserProfile () {
        self.txtName.text = fbUserData.value(forKey: "name") as? String
        self.txtEmail.text = (fbUserData.value(forKey: "email") as? String ?? "")
        self.txtPassword.text = "test12"
        self.txtConfirmPassword.text = "test12"
        self.txtPassword.isHidden = true
        self.txtConfirmPassword.isHidden = true
        self.lblPassLabel.isHidden = true
        self.lblConfirmPassLabel.isHidden = true
    }
    
    @IBAction func btnBackButton (_ id: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnActionForSignup(_ sender: Any) {
        self.view.endEditing(true)
        if (txtName.text?.trim().isEmpty)!{
            txtName.shake()
        } else  if(txtEmail.text?.trim().isEmpty)!{
            txtEmail.shake()
        } else if !Utility.isValidEmail(testStr: txtEmail.text!){
            self.showAlert(strMessage: ConstantsMessages.msgValidEmail)
        } else if (txtStoreName.text?.trim().isEmpty)!{
            txtStoreName.shake()
        }else if (txtStoreAddress.text?.trim().isEmpty)!{
            txtStoreAddress.shake()
        }else  if(txtPassword.text?.trim().isEmpty)!{
            txtPassword.shake()
        } else if !(checkValidation(password: txtPassword.text!)){
            self.showAlert(strMessage: ConstantsMessages.msgValidPassword)
        } else  if(txtConfirmPassword.text?.trim().isEmpty)!{
            txtConfirmPassword.shake()
        } else if txtPassword.text != txtConfirmPassword.text {
            self.showAlert(strMessage: ConstantsMessages.msgPasswordShouldSame)
        } else {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(txtStoreAddress.text!) {
                placemarks, error in
                let placemark = placemarks?.first
               
                if(placemark != nil) {
                    let numLat = NSNumber(value: (placemark?.location?.coordinate.latitude)! as Double)
                    let stLat:String = numLat.stringValue
                    
                    let numLon = NSNumber(value: (placemark?.location?.coordinate.longitude)! as Double)
                    let stLon:String = numLon.stringValue
                    
                    self.strLat = stLat
                    self.strLong = stLon
                } else {
                    self.strLat = "0.00"
                    self.strLong = "0.00"
                }
                
                self.callApiForSignup()
            }
        }
    }
    
    @IBAction func btnLocationPicker (_ id: Any) {
        showPicker()
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        showSideMenu()
    }
    
    
    func callApiForSignup(){
        
        Utility.showHUD(msg: "")
        
        if Constants.objDefault.value(forKey: Constants.Key_DeviceToken) == nil {
            Constants.objDefault.set("", forKey: Constants.Key_DeviceToken)
        }
        
        let strToken:String = Constants.objDefault.value(forKey: Constants.Key_DeviceToken) as! String
        
        let strAddress: String = self.txtStoreAddress.text!
        
         var param =  [String: Any]()
            
           if (fbUserData.count != 0) {
            param = ["fbid":fbUserData.value(forKey: "id") ?? "","logintype":"1","devicetoken":strToken,"fullname":txtName.text!,"gender":"","UserTypes":"2","DeviceType":"1","UserID":"0","StoreName":txtStoreName.text!,"StoreDesc":"","Address":strAddress,"ProfileStatus":"","email":txtEmail.text!,"password":txtPassword.text!,"phoneno":"","Latitude":self.strLat,"Longitude":self.strLong,"BagSpace":"0"]
           } else {
            param = ["fbid":"","logintype":"1","devicetoken":strToken,"fullname":txtName.text!,"gender":"","UserTypes":"2","DeviceType":"1","UserID":"0","StoreName":txtStoreName.text!,"StoreDesc":"","Address":strAddress,"ProfileStatus":"","email":txtEmail.text!,"password":txtPassword.text!,"phoneno":"","Latitude":self.strLat,"Longitude":self.strLong,"BagSpace":"0"]
          }
        
        APIManager.getRequestWith(strURL: Constants.requestAPISignUP, Param: param) { (dict, error) in
            Utility.hideHUD()
            if error == nil{
                if let value = dict{
                    print(value)
                    if ((value.object(forKey: "code")) as! Int == 100) {
                        
                        var valueToStore =  [String: Any]()
                        var fbId : String = ""
                        var imagePath : String = ""
                        
                        if (self.fbUserData.count != 0) {
                            fbId = self.fbUserData.value(forKey: "id") as! String
                            let dic = self.fbUserData.value(forKey: "picture") as! NSDictionary
                            let data = dic.value(forKey: "data") as! NSDictionary
                            imagePath = data.value(forKey: "url") as! String
                        } else {
                            fbId = ""
                            imagePath = ""
                        }
                        
                        valueToStore = ["email":self.txtEmail.text!,"password":self.txtPassword.text ?? "","fullname":self.txtName.text!,"fbid":fbId,"deviceToken":strToken,"imagepath":imagePath,"userId":value.object(forKey: "UserID") ?? "","userType":"2","Address":self.txtStoreAddress.text!,"StoreName":self.txtStoreName.text!,"StoreDesc":"","latitude":self.strLat,"longitude":self.strLong] as [String : Any]
                        
                        let user = User.init(dic: valueToStore)
                        user.userType = "2"
                        User.shared.saveUser(user: user)
                      
                        SharedProperties.setLoggedIn()
                        FireBaseManager.sharedInstance.signupUser(email: self.txtEmail.text!)
                        
                        let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let notificationViewController = storyBoard.instantiateViewController(withIdentifier: "termsAndPrivacyView")
                        self.present(notificationViewController, animated: true, completion: nil)
                        
                        //self.showAlert(strMessage: "You have successfully signup.")
                    } else {
                        let strMsg = (value.object(forKey: "Message")) as! String
                        if (strMsg.contains("already")) {
                             self.showAlert(strMessage: "Email already exist, use different email as a bag handler.")
                        } else {
                             self.showAlert(strMessage:strMsg)
                        }
                      
                       
                    }
                }
            }
        }
    }
    
    func showPicker()
    {
        self.view.endEditing(true)
        var center = CLLocationCoordinate2DMake(AppDelegate.objAppDelegate.currentLat, AppDelegate.objAppDelegate.currentLong)
        
        if selectedPlace != nil {
            center = selectedPlace.coordinate
        }
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let  placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromSignup != nil {
            return signupCell.count
        }else {
            return sideMenuCell.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFromSignup != nil {
            return signupCell[indexPath.row]
        }else {
            return sideMenuCell[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFromSignup != nil {
            let cell = signupCell[indexPath.row]
            return CGFloat(cell.tag)
        }else {
            let cell = sideMenuCell[indexPath.row]
            return CGFloat(cell.tag)
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

}


extension BagHandlerSignupViewController:GMSPlacePickerViewControllerDelegate {
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
        
        txtStoreAddress.text = address
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
}


extension BagHandlerSignupViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtName {
            txtEmail.becomeFirstResponder()
        }else if textField == txtEmail {
            txtStoreName.becomeFirstResponder()
        }else if textField == txtStoreName {
            txtStoreAddress.becomeFirstResponder()
        } else if textField == txtStoreAddress {
            txtPassword.becomeFirstResponder()
        }else if textField == txtPassword {
            txtConfirmPassword.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func checkValidation(password : String) -> Bool{
        let passwordTest = NSPredicate(format:
            "SELF MATCHES %@", "^(?=.*[!@#$&*])(?=.*[a-z].*[a-z].*[a-z].*[a-z].*[a-z]).{6,15}$")
        return passwordTest.evaluate(with: password)
    }
}
