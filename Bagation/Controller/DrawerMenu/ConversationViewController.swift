//
//  ConversationViewController.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import TLPhotoPicker
import IQKeyboardManagerSwift

class ConversationViewController: UIViewController {

    let cellId = "chatCell"
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var btnSend:UIButton!
    @IBOutlet weak var btnPicker:UIButton!
    @IBOutlet weak var textView:MBAutoGrowingTextView!
    var objUser:StorageDAO!
    var messages = [Chat]()
    var strName:String! = ""
    var ID:String! = ""

    @IBOutlet weak var layoutConstBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSValue) as? Double
            {
            let keyboardHeight = keyboardSize.height
            let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
                
            self.layoutConstBottom.constant = -keyboardHeight
            
            UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue:curve), animations: {
                self.view.layoutIfNeeded()
                if !self.messages.isEmpty {
                    self.collectionView.scrollToItem(at:IndexPath(row: self.messages.count-1, section: 0)  , at: UICollectionViewScrollPosition.bottom, animated: true)
                }
            }, completion: nil)
            
        }
        //handle appearing of keyboard here
        
    }
    
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        //handle dismiss of keyboard here
        if let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSValue) as? Double
        {
            let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
            self.layoutConstBottom.constant = 0
            UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue:curve), animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        messages.removeAll()
        self.praperLayout()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
  
    
    func praperLayout(){
        if self.objUser.StoreName.isEmpty {
            strName = self.objUser.DisplayName
            
        }else {
            strName = self.objUser.StoreName
            
        }
        ID = objUser.BagHandlerFireBaseID
        if ID.isEmpty {
            ID = objUser.FirBaseID
        }
        self.title = strName
        print(ID)
        configureNavigationWithTitle()
        collectionView.alwaysBounceVertical = true
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 30
        collectionView!.collectionViewLayout = layout
        
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        self.textView.placeholder = "Type a meessage"
        messages.removeAll()
        self.getMessage()
        
        FireBaseManager.sharedInstance.dataBase.child("images").child(ID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.objUser.FirebaseReceiverOnlineStatus = value?.object(forKey: "isOnline") as? String
            self.objUser.FirebaseReceiverDeviceToken = value?.object(forKey: "deviceToken") as? String
            print(value ?? "")
        }) { (error) in
            print(error.localizedDescription)
        }
       
        FireBaseManager.sharedInstance.updateImageForLastMessage(toID: ID)
      //  self.textView.placeholderColor = .white
    }
    
    func getMessage(){
       
        FireBaseManager.sharedInstance.getMessages(toID:ID!) { (Message, errorMSG) in
            self.messages.append(Message!)
            self.collectionView.reloadData()
            if !self.messages.isEmpty {
                let indexPath = IndexPath.init(row:  self.messages.count-1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
            }
        }
        
    }
    

    @IBAction func btnSendMessage(_ sender: UIButton) {
        /*if (objUser.FirebaseReceiverOnlineStatus == "true") {
            self.sendMessgae(text: textView.text, type: .text)
            textView.text = ""
        } else if (objUser.FirebaseReceiverOnlineStatus == "false") {
            if (objUser.FirebaseReceiverDeviceToken != "") {
                APIManager.sendFCMPushNotification(token: objUser.FirebaseReceiverDeviceToken)
            }
            self.sendMessgae(text: textView.text, type: .text)
            textView.text = ""
        } else {
            self.sendMessgae(text: textView.text, type: .text)
            textView.text = ""
        }*/
        if (objUser.FirebaseReceiverDeviceToken != "") {
            APIManager.sendFCMPushNotification(token: objUser.FirebaseReceiverDeviceToken)
        }
        self.sendMessgae(text: textView.text, type: .text)
        textView.text = ""
        if !self.messages.isEmpty {
            let indexPath = IndexPath.init(row: messages.count-1, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
        }
    }
    
    @IBAction func btnUploadImage(_ sender: UIButton) {
        //self.openPicker()
    }
    
    func sendMessgae(text:String,type:messageType){
        FireBaseManager.sharedInstance.sendMessage(text: text, toUser: strName, toID: ID, mediaType: type ) { (isSuccess, errorMSG) in
            
        }
    }
    
    func openPicker(){
        let viewController = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            //     self?.selectedAssets = assets
            self?.getSelectedImage(obj: assets[0])
            }, didCancel: nil)
        viewController.didExceedMaximumNumberOfSelection = { (picker) in
            //exceed max selection
        }
        viewController.selectedAssets = [TLPHAsset]()
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.allowedVideo =  false
        configure.maxSelectedAssets = 1
        configure.usedCameraButton = true
        configure.usedPrefetch = false
        viewController.configure = configure
        self.present(viewController, animated: true, completion: nil)
    }
    
    func getSelectedImage(obj:TLPHAsset){
    
        if obj.fullResolutionImage != nil {
            self.sendImage(img: obj.fullResolutionImage!)
        }
    }
    
    func sendImage(img:UIImage){
        FireBaseManager.sharedInstance.uploadImage(image: img) { (imgURL, errorMSG) in
            if let url = imgURL {
                self.sendMessgae(text: url, type: .image)
            }
        }
    }
    func getImage(url:String?,callback: ((_ image:UIImage?) -> Void)?){
        let imgView = UIImageView()
        guard let imgUrl = URL(string: url!)  else {
            callback!(nil)
            return
        }
        imgView.sd_setImage(with: imgUrl, placeholderImage: nil) { (img, _, _, _) in
            callback!(img)
        }
    }
    
    func convertTime(strDate:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: strDate)!
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        return dateString
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


extension ConversationViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:ChatCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatCell
        let message = messages[indexPath.row]
        if (message.userID == FireBaseManager.sharedInstance.getCurrentUser()){
            cell.textView.isHidden                  = false
            cell.deliverImg.isHidden                = false
            cell.textViewOther.isHidden             = true
            cell.lblTimeStampLeft.isHidden          = true
            cell.lblTimeStampRight.isHidden         = false
            cell.bubbleViewRightAnchor?.isActive    = true
            cell.bubbleViewLeftAnchor?.isActive     = false
        
           if message.mediaType == .text {
             cell.textView.text                 = message.text
           }

           }else{
           if message.mediaType == .text {
            cell.textViewOther.text                 = message.text
           }
            cell.bubbleViewRightAnchor?.isActive    = false
            cell.bubbleViewLeftAnchor?.isActive     = true
            cell.deliverImg.isHidden                = true
            cell.textView.isHidden                  = true
            cell.textViewOther.isHidden             = false
            cell.lblTimeStampLeft.isHidden          = false
            cell.lblTimeStampRight.isHidden         = true
        }
        cell.deliverImg.isHidden                = true
        cell.lblTimeStampLeft.text = self.convertTime(strDate: message.date!)
        cell.lblTimeStampRight.text = self.convertTime(strDate: message.date!)
        cell.bubbleWidthAnchor?.constant = message.text.estimateFrameForText()
        cell.lblTimeStampLeft.textColor = UIColor.lightGray
        cell.lblTimeStampRight.textColor = UIColor.lightGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages[indexPath.row]

        var bubbleHeight : CGFloat = 0
        if message.mediaType == .text {
            bubbleHeight = message.text.height(withConstrainedWidth: Constants.defaultMessageBubbleTextInViewMaxWidth, font: UIFont.systemFont(ofSize: 12.5))
        }else {
             bubbleHeight  =   100
        }
        return CGSize(width: collectionView.frame.width, height:bubbleHeight+30)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //collectionView.collectionViewLayout.invalidateLayout()
    }
}
