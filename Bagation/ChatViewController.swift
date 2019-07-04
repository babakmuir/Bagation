//
//  ChatViewController.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import InteractiveSideMenu

class ChatViewController: UIViewController,SideMenuItemContent {

    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var lblNoResult: UILabel!

    var chatList = [Inbox]()
    var strNav:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureNavigation()
        tblChat.dataSource = self
        tblChat.delegate = self
        tblChat.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getConversationList()
        
        if strNav != nil{
            configureNavigationWithTitle()
            self.title = "Inbox"
        }else{
            configureNavigation()
            let img = #imageLiteral(resourceName: "icon-menu")
            if let parent = self.parent {
                let btnback = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.openMenuAction))
                parent.navigationItem.leftBarButtonItem = btnback
                parent.title = "Inbox"
            }
        }
    }
    
    @objc func openMenuAction(){
        showSideMenu()
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        showSideMenu()
    }


    func getConversationList(){
         Utility.showHUD(msg: "")
        self.chatList = [Inbox]()
        FireBaseManager.sharedInstance.getInboxList { (results, errorMSG) in
            Utility.hideHUD()
            if (errorMSG?.isEmpty)! {
                self.chatList = results!
                self.tblChat.isHidden = false
                self.lblNoResult.isHidden = true
            }
            self.tblChat.reloadData()
            if self.chatList.count == 0 {
                self.lblNoResult.isHidden = false
                self.tblChat.isHidden = true
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


extension ChatViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:InboxCell = tableView.dequeueReusableCell(withIdentifier: "inboxCell") as! InboxCell? else {
            
            return UITableViewCell()
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if (chatList.count != 0) {
            let inbox = chatList[indexPath.row]
            print("name %@",inbox.receiverName)
            print("message %@",inbox.text)
            print("image %@",inbox.receiverPic)
            print("devicetoken %@",inbox.receiverDeviceToken)
            print("online status %@",inbox.receiverOnlineStatus)
            
            cell.lblUserName.text = inbox.receiverName
            cell.lblLastMessage.text = inbox.text
            if (inbox.receiverPic.count != 0) {
                cell.imgProfile.setImageWith(URL.init(string: inbox.receiverPic)!, usingActivityIndicatorStyle: .gray)
                cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height/2.0
                cell.imgProfile.layer.masksToBounds = true
            } else {
                cell.imgProfile.image = UIImage.init(named: "avatar")
                cell.imgProfile.backgroundColor = UIColor.gray
            }
            
        }
        cell.lblCount.isHidden = true
        
      //  cell.lblCount.layer.cornerRadius = cell.lblCount.frame.size.height/2
      //  cell.lblCount.layer.masksToBounds = true
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let inbox = chatList[indexPath.row]
        let store = StorageDAO(storageDict: [:])
        if (inbox.userID == FireBaseManager.sharedInstance.getCurrentUser()){
            store.FirBaseID = inbox.receiverID
        }else {
            store.FirBaseID = inbox.userID
        }
        store.DisplayName = inbox.receiverName
        store.FirebaseReceiverDeviceToken = inbox.receiverDeviceToken
        store.FirebaseReceiverOnlineStatus = inbox.receiverOnlineStatus
        let obj:ConversationViewController = self.storyboard?.instantiateViewController(withIdentifier: "conversationView") as! ConversationViewController
        obj.objUser = store
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
}

