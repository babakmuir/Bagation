//
//  SignInViewController.swift
//  Hope
//
//  Created by Vivek Soni on 16/09/17.
//  Copyright © 2017 Vivek Soni. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController {
    // IBOutLets :-
    
    @IBOutlet weak var txtEmail             : UITextField!
    @IBOutlet weak var txtPassword          : UITextField!
    @IBOutlet weak var btnSignIn          : UIButton!
    
    var appMode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurView(_:)))
        self.view.addGestureRecognizer(tapGesture)
        txtEmail.autocorrectionType = .no
        txtPassword.autocorrectionType = .no
        // Do any additional setup after loading the view.
        
        //txtEmail.text = "jay@pinstripemedia.com.au"
        //txtPassword.text = "mahalkita"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Gesture Method For Hide Keyboard
    
    @objc func tapBlurView(_ sender: UITapGestureRecognizer) {
        print("Please Help!")
        self.view.endEditing(true)
    }
    
    // MARK: - IBAction
    
    @IBAction func btnActionForSignIn(_ sender: Any) {
        self.view.endEditing(true)
        if (txtEmail.text?.trim().isEmpty)!{
            txtEmail.shake()
        } else if !Utility.isValidEmail(testStr: txtEmail.text!) {
            self.showAlert(strMessage: ConstantsMessages.msgValidEmail)
        } else if (txtPassword.text?.trim().isEmpty)!{
            txtPassword.shake()
        } else {
            self.CallApiForLogin(strID: "")
        }
    }
    
    // MARK: - API For Login
    func CallApiForLogin(strID:String){
        if (AppDelegate.objAppDelegate.isConnectedToInternet()) {
            Utility.showHUD(msg: "")
            
            //DeviceType = 1 for ios
            
            if UserDefaults.standard.object(forKey: Constants.Key_DeviceToken) == nil
            {
                UserDefaults.standard.set("", forKey: Constants.Key_DeviceToken)
            }
            
            let strToken = UserDefaults.standard.value(forKey: Constants.Key_DeviceToken) as! String
            
            
            let value = ["email": self.txtEmail.text! , "password": self.txtPassword.text!, "devicetoken":strToken,"fbid":"" ,"IsAdminLogin":"0","DeviceType":"1","UserType": self.appMode]
            
            print(self.appMode) // traveller = 1, owner = 2
            UserDefaults.standard.set(self.appMode, forKey: "userType")
            UserDefaults.standard.synchronize()
            
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
                            let isOnline = String (describing:value.value(forKey: "IsOnline") as? String ?? "False")
                            let availabilityDays = String (describing:value.value(forKey: "AvailabilityDays") as? String ?? "")
                            UserDefaults.standard.set(isOnline, forKey: "IsOnline")
                            UserDefaults.standard.set(availabilityDays, forKey: "days")
                            UserDefaults.standard.synchronize()
//                            let bagHandlerID = String (describing:value.value(forKey: "UserID")!)
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
                                valueToStore = ["email":self.txtEmail.text!,"password": self.txtPassword.text!,"fullname":value.value(forKey: "DisplayName") ?? "","fbid":"","phoneno":value.value(forKey: "Phone") ?? "","deviceToken":strToken,"userId":userID,"imagepath":imagePath,"userType":userType,"Address":value.value(forKey: "Address") ?? "","StoreName":value.value(forKey: "StoreName") ?? "","StoreDesc":value.value(forKey: "StoreDesc") ?? "","BagSpace":value.value(forKey: "BagSpace") ?? "","latitude":value.value(forKey: "Latitude") ?? "","longitude":value.value(forKey: "Longitude") ?? "","StartTime":startTime,"EndTime":endTime] as [String : Any]
                                
                            } else {
                                let userID = String (describing:value.value(forKey: "UserID")!)
                                
                                valueToStore = ["email":self.txtEmail.text!,"password": self.txtPassword.text!,"fullname":value.value(forKey: "DisplayName") ?? "","fbid":"","deviceToken":strToken,"userId":userID,"imagepath":imagePath,"phoneno":value.value(forKey: "Phone") ?? "","userType":userType] as [String : Any]
                            }
                            
                            
                            print(valueToStore)
                            let user = User.init(dic: valueToStore)
                            
                            User.shared.saveUser(user: user)
                            SharedProperties.setLoggedIn()
                            
                            FireBaseManager.sharedInstance.loginUser(email: self.txtEmail.text!, callback: { (_, _) in
                            })
                            AppDelegate.objAppDelegate.setHomeRootView()
                        } else {
                            self.showAlert(strMessage: (value.object(forKey: "Message")) as! String)
                        }
                    }
                } else {
                    self.showAlert(strMessage: "")
                }
            }
        } else {
             self.showAlert(strMessage: Constants.errorNetworkMessage)
        }
    }
    
    // MARK: - UItextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if txtEmail == textField{
            txtPassword.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
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
