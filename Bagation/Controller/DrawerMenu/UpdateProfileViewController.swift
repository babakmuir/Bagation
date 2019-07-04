//
//  UpdateProfileViewController.swift
//  Bagation
//
//  Created by vivek soni on 31/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import Photos
import InteractiveSideMenu

class UpdateProfileViewController: UIViewController,SideMenuItemContent,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var txtName                          : UITextField!
    @IBOutlet weak var txtEmail                         : UITextField!
    @IBOutlet weak var txtPhoneNo                       : UITextField!
    @IBOutlet weak var btnImageProfile                  : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPermission()
        let userObj = User.shared
        self.txtName.text = userObj.fullname.capitalized(with: NSLocale.current)
        self.txtEmail.text = userObj.email
        self.txtPhoneNo.text = userObj.phoneno
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
        // Do any additional setup after loading the view.
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigation()
        let img = #imageLiteral(resourceName: "icon-menu")
        if let parent = self.parent {
            let btnback = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.openMenuAction))
            parent.navigationItem.leftBarButtonItem = btnback
            parent.title = "Complete Your Profile"
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   @objc func openMenuAction(){
    showSideMenu()
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        showSideMenu()
    }

    @IBAction func btnUpdateProfie(_ sender: UIButton) {
        self.view.endEditing(true)
        if (txtName.text?.trim().isEmpty)!{
            txtName.shake()
        } else  if(txtEmail.text?.trim().isEmpty)!{
            txtEmail.shake()
        } else if !Utility.isValidEmail(testStr: txtEmail.text!){
            self.showAlert(strMessage: ConstantsMessages.msgValidEmail)
        } else  if(txtPhoneNo.text?.trim().isEmpty)!{
            txtPhoneNo.shake()
        } else {
            self.CallApiForSignup()
        }
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
    
    @IBAction func updatePasswordButton(_ sender: Any) {
        
        if (txtEmail.text!.isEmpty || txtName.text!.isEmpty || txtPhoneNo.text!.isEmpty) {
            
            showAlert(strMessage: "Please fill empty text fields")
            
        } else {
            
            performSegue(withIdentifier: "travellerToUpdatePassword", sender: self)
            
        }
        
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
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        
//        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            
//        }
//        
//        dismiss(animated: true, completion: nil)
//    }
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let compressedImage = UIImage(data: UIImageJPEGRepresentation(chosenImage, 0.70)!)!
        
        // use the image
        btnImageProfile.setImage(chosenImage, for: .normal)
        btnImageProfile.layer.cornerRadius =  self.btnImageProfile.frame.size.height/2.0
        btnImageProfile.layer.masksToBounds = true
        btnImageProfile.layer.borderWidth = 2.0
        btnImageProfile.layer.borderColor = UIColor.white.cgColor
        self.uploadProfilePic(Image: compressedImage)
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UItextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if txtName == textField{
            txtEmail.becomeFirstResponder()
        } else if txtEmail == textField{
            txtPhoneNo.becomeFirstResponder()
        } else if txtPhoneNo == textField{
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
            
            param = ["email":txtEmail.text!,"password":objUser.password,"DeviceType":"1","fullname":txtName.text!,"phoneno":txtPhoneNo.text ?? "","fbid":objUser.fbId,"logintype":"1","deviceToken":strToken,"gender":"1","UserTypes":"1","UserID":objUser.userId] as [String : Any]
            
            print(param)
            
            APIManager.getRequestWith(strURL: Constants.requestAPISignUP, Param: param) { (Dict, Error) in
                Utility.hideHUD()
                if Error == nil{
                    if let value = Dict{
                        print(value)
                        if ((value.object(forKey: "code")) as! Int == 100) {
                            
                            var valueToStore =  [String: Any]()
                            let objUser = User.shared
                            valueToStore = ["email":self.txtEmail.text!,"password":objUser.password,"fullname":self.txtName.text!,"fbid":objUser.fbId,"deviceToken":strToken,"imagepath":objUser.imagepath,"userId":objUser.userId,"UserTypes":"1","phoneno":self.txtPhoneNo.text ?? ""] as [String : Any]
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
    
    func uploadProfilePic(Image:UIImage){
        self.btnImageProfile.loadingIndicator(show: true)
        
        APIManager.uploadImageWith(img: Image) { (dict, error) in
            self.btnImageProfile.loadingIndicator(show: false)
            if (error == nil) {
                if let value = (dict!["UploadProfilePhotoNewResult"] as! [String:Any])["ProfilePhoto"] {
                    let strValue:String = value as! String
                    UserDefaults.standard.set(strValue, forKey: Constants.Key_UserProfilePic)
                    User.shared.loadUser()
                    let user = User.shared
                    user.imagepath = strValue
                    User.shared.saveUser(user: user)
                    FireBaseManager.sharedInstance.insertUserImage()
                }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "travellerToUpdatePassword" {
            let destination = segue.destination as? UpdatePasswordViewController
            
            destination!.emailText = txtEmail.text!
            destination?.fullName = txtName.text!
            destination?.phoneNumber = txtPhoneNo.text!
            
        }
        
    }

}
