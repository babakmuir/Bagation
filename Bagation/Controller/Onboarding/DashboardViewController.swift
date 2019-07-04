//
//  DashboardViewController.swift
//  Bagation
//
//  Created by vivek soni on 01/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookLogin
import FacebookCore


class DashboardViewController: UIViewController {

    var appMode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackButton (_ id: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnFaceBookAction(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile,.email], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print(grantedPermissions)
                print(declinedPermissions)
                print(accessToken)

                self.getUserInfo()
                print("Logged in!")
            }
        }
    
    }
    
    @IBAction func btnGoogleAction(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    @IBAction func btnSignInAction(_ sender: Any) {
        let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let signinViewController = storyBoard.instantiateViewController(withIdentifier: "signin") as! SignInViewController
        signinViewController.appMode = self.appMode
        self.present(signinViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnSignUpAction(_ sender: Any) {
        if (appMode == "1") {
            let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let dashboardViewController = storyBoard.instantiateViewController(withIdentifier: "signup") as! SignUpViewController
            dashboardViewController.appMode = "1"
            self.present(dashboardViewController, animated: true, completion: nil)
        } else {
            let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let dashboardViewController = storyBoard.instantiateViewController(withIdentifier: "bagHandlerSignupView") as! BagHandlerSignupViewController
            dashboardViewController.appMode = "2"
            dashboardViewController.isFromSignup = "2"
            self.present(dashboardViewController, animated: true, completion: nil)
        }
    }
    
    private func getUserInfo()
    {
        let params = ["fields":"cover,picture.type(large),id,name,first_name,last_name,gender,email,location,birthday"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params)
        
        graphRequest.start {
            (urlResponse, requestResult) in
            
            switch requestResult {
            case .failed(let error):
                print("error in graph request:", error)
                break
            case .success(let graphResponse):
                
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    self.CallApiForLogin(dicData: responseDictionary as NSDictionary)
                }
            }
        }
    }
    
    func CallApiForSignup(dicData:NSDictionary) {
        if (AppDelegate.objAppDelegate.isConnectedToInternet()) {
            Utility.showHUD(msg: "")
            
            if UserDefaults.standard.object(forKey: Constants.Key_DeviceToken) == nil
            {
                UserDefaults.standard.set("", forKey: Constants.Key_DeviceToken)
            }
            
            let strToken = UserDefaults.standard.value(forKey: Constants.Key_DeviceToken) as! String
            
            var param =  [String: Any]()
            
            param = ["email":dicData.value(forKey: "email") as? String ?? "","password": "","DeviceType":"1","fullname":dicData.value(forKey: "name") as? String ?? "","phoneno":"","fbid":dicData.value(forKey: "id") ?? "","logintype":"1","deviceToken":strToken,"gender":"1","UserTypes":"1","UserID":"0","Latitude":"","Longitude":""] as [String : Any]
            
            
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
                            
                            fbId = dicData.value(forKey: "id") as? String ?? ""
                            let dic = dicData.value(forKey: "picture") as! NSDictionary
                            let data = dic.value(forKey: "data") as! NSDictionary
                            imagePath = data.value(forKey: "url") as! String
                            
                            let userID = String (describing:value.object(forKey: "UserID")!)
                            
                            Constants.objDefault.set(userID, forKey: Constants.key_UserID)
                            
                            valueToStore = ["email":dicData.value(forKey: "email") as? String ?? "","password":"","fullname":dicData.value(forKey: "name") as? String ?? "","fbid":fbId,"deviceToken":strToken,"imagepath":imagePath,"userId":userID,"userType":"1"] as [String : Any]
                            
                            let user = User.init(dic: valueToStore)
                            user.userType = "1"
                            User.shared.saveUser(user: user)
                            SharedProperties.setLoggedIn()
                            FireBaseManager.sharedInstance.signupUser(email: dicData.value(forKey: "email") as? String ?? "")
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
    
    func CallApiForLogin(dicData:NSDictionary){
        Utility.showHUD(msg: "")
        
        //DeviceType = 1 for ios
        if UserDefaults.standard.object(forKey: Constants.Key_DeviceToken) == nil
        {
            UserDefaults.standard.set("", forKey: Constants.Key_DeviceToken)
        }
        
        let strToken = UserDefaults.standard.value(forKey: Constants.Key_DeviceToken) as! String
       
        
        let value:[String:Any] = ["email": "", "password": "", "devicetoken":strToken,"fbid":dicData.value(forKey: "id")! ,"IsAdminLogin":"0","DeviceType":"1","UserType": self.appMode]
      
        print (value)
        APIManager.getRequestWith(strURL: Constants.requestAPILogin, Param: value) { (Dict, Error) in
            if Error == nil {
                Utility.hideHUD()
                if let value = Dict {
                    print(value)
                    if ((value.object(forKey: "ResponseCode")) as! Int == 200) {
                        var valueToStore =  [String: Any]()
                        var fbId : String = ""
                        var imagePath : String = ""
                       
                        fbId = dicData.value(forKey: "id") as! String
                        let dic = dicData.value(forKey: "picture") as! NSDictionary
                        let data = dic.value(forKey: "data") as! NSDictionary
                        imagePath = data.value(forKey: "url") as! String
                        let userType = String (describing: value.value(forKey: "UserType")!)
                        let userID = String (describing:value.object(forKey: "UserID")!)
                        Constants.objDefault.set(userID, forKey: Constants.key_UserID)
                        valueToStore = ["email":dicData.value(forKey: "email") ?? "","password": "","fullname":dicData.value(forKey: "name") ?? "","fbid":fbId,"deviceToken":strToken,"userId": userID,"imagepath":imagePath,"userType":userType,"phoneno":value.value(forKey: "Phone") ?? ""] as [String : Any]
                        print(valueToStore)
                        let user = User.init(dic: valueToStore)
                        User.shared.saveUser(user: user)
                        User.shared.loadUser()
                        SharedProperties.setLoggedIn()
                        FireBaseManager.sharedInstance.loginUser(email: dicData.value(forKey: "email") as? String ?? "", callback: { (_, _) in
                        })
                        
                        AppDelegate.objAppDelegate.setHomeRootView()
                    } else {
                        if (self.appMode == "1") {
                            self.CallApiForSignup(dicData: dicData)
                        } else {
                            let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let signupView = storyBoard.instantiateViewController(withIdentifier: "bagHandlerSignupView") as! BagHandlerSignupViewController
                            signupView.fbUserData = dicData
                            signupView.isFromSignup = "true"
                            self.present(signupView, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                self.showAlert(strMessage: "")
            }
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


extension DashboardViewController:GIDSignInDelegate,GIDSignInUIDelegate {
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                     withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            //let userId = user.userID                  // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            //let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            //let email = user.profile.email
            // ...
        } else {
            print("\(String(describing: error))")
        }
    }
    
}
