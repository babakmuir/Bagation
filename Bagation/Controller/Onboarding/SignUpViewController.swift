//
//  SignUpViewController.swift
//  Hope
//
//  Created by Vivek Soni on 16/09/17.
//  Copyright © 2017 Vivek Soni. All rights reserved.
//

import UIKit

class SignUpViewController: BaseViewController,UINavigationControllerDelegate,UIGestureRecognizerDelegate {

   
    @IBOutlet weak var txtName                          : UITextField!
    @IBOutlet weak var txtEmail                         : UITextField!
    @IBOutlet weak var txtPassword                      : UITextField!
    @IBOutlet weak var txtConfirmPassword               : UITextField!
    @IBOutlet weak var txtTermsService               : UITextView!
    
    @IBOutlet weak var btnSignup                        : UIButton!
    @IBOutlet weak var btnBack                          : UIButton!
    @IBOutlet weak var btnGroupSelection                : UIButton!
    @IBOutlet weak var lblPassLabel                     : UILabel!
    @IBOutlet weak var lblConfirmPassLabel             : UILabel!
    
    var selectedGroup : String = "0"
    var fbUserData : NSDictionary = [:]
    var appMode: String = ""
    var tapTerm:UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtEmail.isUserInteractionEnabled = true
        self.navigationController?.isNavigationBarHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurView(_:)))
        self.view.addGestureRecognizer(tapGesture)
        //self.btnSignup.setbackroundColorWithCorner()
        //btnSignup.setTitle("SIGN UP", for: .normal)
        // Do any additional setup after loading the view.
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
        termsViewController.comingFor = "1"
        self.present(termsViewController, animated: true, completion: nil)
        
    }
    
    
    //MARK - Gesture recognizer delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: viewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    //MARK: viewWillDisappear
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
    }

    //MARK: Gesture Selector
    @objc func tapBlurView(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func prepareFBUserProfile () {
        self.txtName.text = fbUserData.value(forKey: "name") as? String
        self.txtEmail.text = (fbUserData.value(forKey: "email") as! String)
        self.txtPassword.text = "test12"
        self.txtConfirmPassword.text = "test12"
        self.txtPassword.isHidden = true
        self.txtConfirmPassword.isHidden = true
        self.lblPassLabel.isHidden = true
        self.lblConfirmPassLabel.isHidden = true
    }
    
    @IBAction func btnActionForSignup(_ sender: Any) {
        self.view.endEditing(true)
        
        if (txtName.text?.trim().isEmpty)!{
            txtName.shake()
        } else  if(txtEmail.text?.trim().isEmpty)!{
            txtEmail.shake()
        } else if !Utility.isValidEmail(testStr: txtEmail.text!){
            self.showAlert(strMessage: ConstantsMessages.msgValidEmail)
        } else  if(txtPassword.text?.trim().isEmpty)!{
            txtPassword.shake()
        } else if (!checkValidation(password: txtPassword.text!)) {
            self.showAlert(strMessage: ConstantsMessages.msgValidPassword)
        } else  if(txtConfirmPassword.text?.trim().isEmpty)!{
            txtConfirmPassword.shake()
        } else if txtPassword.text != txtConfirmPassword.text {
            self.showAlert(strMessage: ConstantsMessages.msgPasswordShouldSame)
        } else {
            self.CallApiForSignup()
        }
        
//        if let passwordText = txtPassword.text {
//
//            checkValidation(password: passwordText)
//
//        }
        
    }
    
    // MARK: - UItextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if txtName == textField{
            txtEmail.becomeFirstResponder()
        }else if txtEmail == textField{
            txtPassword.becomeFirstResponder()
        }
        else if txtPassword == textField{
            txtConfirmPassword.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - API For Signup
    func CallApiForSignup() {
        if (AppDelegate.objAppDelegate.isConnectedToInternet()) {
            Utility.showHUD(msg: "")
            if UserDefaults.standard.object(forKey: Constants.Key_DeviceToken) == nil
            {
                UserDefaults.standard.set("", forKey: Constants.Key_DeviceToken)
            }
            
            let strToken = UserDefaults.standard.value(forKey: Constants.Key_DeviceToken) as! String
            
            var param =  [String: Any]()
            
            //logintype=1 1=register and 2=fb
            //DeviceType = 1 1=ios and 2= android
            //UserTypes=1 , 1=traveller and 2=baghandler
            if (fbUserData.count != 0) {
                
                param = ["email":txtEmail.text!,"password": "","DeviceType":"1","fullname":txtName.text!,"phoneno":"","fbid":fbUserData.value(forKey: "id") ?? "","logintype":"1","deviceToken":strToken,"gender":"1","UserTypes":"1","UserID":"0","Latitude":"","Longitude":""] as [String : Any]
                
            } else {
                param = ["email":txtEmail.text!,"password":txtPassword.text ?? "","DeviceType":"1","fullname":txtName.text!,"phoneno":"","fbid":"","logintype":"1","deviceToken":strToken,"gender":"1","UserTypes":"1","UserID":"0","Latitude":"","Longitude":""] as [String : Any]
                
            }
        
            print(param)
        
            APIManager.getRequestWith(strURL: Constants.requestAPISignUP, Param: param) { (Dict, Error) in
                 Utility.hideHUD()
                if Error == nil{
                    if let value = Dict{
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
                            let userID = String (describing:value.object(forKey: "UserID")!)
                            
                            Constants.objDefault.set(userID, forKey: Constants.key_UserID)
                            
                            valueToStore = ["email":self.txtEmail.text!,"password":self.txtPassword.text ?? "","fullname":self.txtName.text!,"fbid":fbId,"deviceToken":strToken,"imagepath":imagePath,"userId":userID,"userType":"1"] as [String : Any]
                            
                            let user = User.init(dic: valueToStore)
                            user.userType = "1"
                            User.shared.saveUser(user: user)
                            SharedProperties.setLoggedIn()
                            FireBaseManager.sharedInstance.signupUser(email: self.txtEmail.text!)
                            //self.showAlert(strMessage: "You have successfully signup.")
                            
                            //For Traveller, There is no terms and privacy screen.
                            let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let notificationViewController = storyBoard.instantiateViewController(withIdentifier: "termsAndPrivacyView") as! TermsAndPrivacyViewController
                            self.present(notificationViewController, animated: true, completion: nil)
                           
                        } else {
                            self.showAlert(strMessage: (value.object(forKey: "Message")) as! String)
                        }
                    }
                }
            }
        } else {
            self.showAlert(strMessage: Constants.errorNetworkMessage)
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
    
    func checkValidation(password : String) -> Bool{
        let passwordTest = NSPredicate(format:
            "SELF MATCHES %@", "^(?=.*[!@#$&*])(?=.*[a-z].*[a-z].*[a-z].*[a-z].*[a-z]).{6,15}$")
        return passwordTest.evaluate(with: password)
    }
    
}
