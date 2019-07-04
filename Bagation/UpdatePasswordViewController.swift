//
//  updatePasswordViewController.swift
//  Bagation
//
//  Created by B.Mossavi on 5/27/19.
//  Copyright © 2019 IOSAppExpertise. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: BaseViewController {
    
    var appMode: String = ""
    
    var emailText = ""
    
    var oldPassword = User.shared.password
    
    var fullName = ""
    
    var phoneNumber = ""

    @IBOutlet weak var textPassword: UITextField!
    
    @IBOutlet weak var textNewPassword: UITextField!
    
    @IBOutlet weak var textConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonChangePassword(_ sender: Any) {
        
        if (textPassword.text?.trim().isEmpty)! {
            
            textPassword.shake()
            
        } else if !((oldPassword.elementsEqual(textPassword.text!))) {
            
            showAlert(strMessage: "Please enter current password!")
            
        } else if (textNewPassword.text?.trim().isEmpty)! {
            
            textNewPassword.shake()
            
        } else if !(checkValidation(password: textNewPassword.text!)) {
            
            self.showAlert(strMessage: ConstantsMessages.msgValidPassword)
            
        } else if (textConfirmPassword.text?.trim().isEmpty)! {
            
            textConfirmPassword.shake()
            
        } else if !((textNewPassword.text?.elementsEqual(textConfirmPassword.text!))!) {
            
            showAlert(strMessage: "Please check new password and confirm password section!")
            
        } else {
            
            var confirmPassword = textConfirmPassword.text

            CallApiForSignup(confirmPassword: confirmPassword!)
            
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
//    +61466961935
    func CallApiForSignup(confirmPassword: String){
        Utility.showHUD(msg: "")
        
        if Constants.objDefault.value(forKey: Constants.Key_DeviceToken) == nil {
            Constants.objDefault.set("c316ef470b17b808910ea6e944b4b5789c3dfb18e52b398524696224b075933b", forKey: Constants.Key_DeviceToken)
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
            //logintype=1 1=register and 2=fb
            //DeviceType = 1 1=ios and 2= android
            //UserTypes=1 , 1=traveller and 2=baghandler
            
            param = ["email":emailText,"password":confirmPassword,"DeviceType":"1","fullname":fullName,"phoneno":phoneNumber ?? "","fbid":objUser.fbId,"logintype":"1","deviceToken":strToken,"gender":"1","UserTypes":"1","UserID":objUser.userId] as [String : Any]
            
            print(param)
            
            APIManager.getRequestWith(strURL: Constants.requestAPISignUP, Param: param) { (Dict, Error) in
                Utility.hideHUD()
                if Error == nil{
                    if let value = Dict{
                        print(value)
                        if ((value.object(forKey: "code")) as! Int == 100) {
                            
                            var valueToStore =  [String: Any]()
                            let objUser = User.shared
                            valueToStore = ["email":self.emailText,"password":confirmPassword,"fullname":self.fullName,"fbid":objUser.fbId,"deviceToken":strToken,"imagepath":objUser.imagepath,"userId":objUser.userId,"UserTypes":"1","phoneno":self.phoneNumber ?? ""] as [String : Any]
                            let user = User.init(dic: valueToStore)
                            User.shared.saveUser(user: user)
                            User.shared.loadUser()
                            self.showAlert(strMessage: "You have successfully updated your profile.")
                            FireBaseManager.sharedInstance.insertUserImage()
                            
                        } else {
                            self.showAlert(strMessage: (value.object(forKey: "Message")) as! String)
                        }
                    }
                }
            }
        }
        
    }
    
    
    func checkValidation(password : String) -> Bool{
        let passwordTest = NSPredicate(format:
            "SELF MATCHES %@", "^(?=.*[!@#$&*])(?=.*[a-z].*[a-z].*[a-z].*[a-z].*[a-z]).{6,15}$")
        return passwordTest.evaluate(with: password)
    }

}
