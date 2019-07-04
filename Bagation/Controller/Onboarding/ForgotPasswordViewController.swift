//
//  ForgotPasswordViewController.swift
//  Hope
//
//  Created by Vivek Soni on 16/09/17.
//  Copyright © 2017 Vivek Soni. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {

    @IBOutlet weak var txtEmail                 : UITextField!
    @IBOutlet weak var btnSend                  : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //btnSend.setbackroundColorWithCorner()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurView(_:)))
        self.view.addGestureRecognizer(tapGesture)
        txtEmail.autocorrectionType = .no
        // Do any additional setup after loading the view.
    }

    @objc func tapBlurView(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnActionForSend(_ sender: Any) {
        self.view.endEditing(true)
        if(txtEmail.text?.trim().isEmpty)!{
            txtEmail.shake()
        } else if !Utility.isValidEmail(testStr: txtEmail.text!){
            self.showAlert(strMessage: ConstantsMessages.msgValidEmail)
        }else{
            self.callAPIforForgotPassword()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func callAPIforForgotPassword(){
        Utility.showHUD(msg: "")
        let value = ["Email": self.txtEmail.text! , "UserID": "0"]
//        let value = ["Email": "b.mossavi@gmail.com" , "UserID": "0"]
   
        APIManager.getRequestWith(strURL: Constants.requestForgotPassword, Param: value) { (Dict, Error) in
            Utility.hideHUD()
            if Error == nil {
                if let value = Dict {
                    print(value)
                    if let data = Dict!["InsertResetPasswordResult"] {
                        let dicData = data as! NSDictionary
                        if (dicData.object(forKey: "code")) as! Int == 102 {
                             self.showAlert(strMessage: (dicData.object(forKey: "Message")) as! String)
                        } else {
                            let alertController = UIAlertController(title: "Alert!", message: (dicData.object(forKey: "Message")) as? String, preferredStyle: .alert)
                            
                            // Create the actions
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                self.dismiss(animated: true, completion: nil)
                            }
                            
                            // Add the actions
                            alertController.addAction(okAction)
                            
                            // Present the controller
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                self.showAlert(strMessage: "Server Maintenance going on. Please try again later.")
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
