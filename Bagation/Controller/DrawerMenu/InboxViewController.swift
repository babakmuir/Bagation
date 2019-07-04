//
//  InboxViewController.swift
//  Bagation
//
//  Created by pushpendra on 12/03/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController {
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
        configureNavigationWithTitle()
        self.title = "Inbox"
    }
    
 
  
    
    
    func getConversationList(){
        Utility.showHUD(msg: "")
        FireBaseManager.sharedInstance.getInboxList { (results, errorMSG) in
            Utility.hideHUD()
            if (errorMSG?.isEmpty)! {
                self.chatList = results!
                self.tblChat.reloadData()
                self.lblNoResult.isHidden = true
            }
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


extension InboxViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:InboxCell = tableView.dequeueReusableCell(withIdentifier: "inboxCell") as! InboxCell? else {
            
            return UITableViewCell()
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let inbox = chatList[indexPath.row]
        if (User.shared.userType == "2") {
            cell.lblUserName.text = inbox.receiverName
        } else {
            cell.lblUserName.text = inbox.senderName
        }
        
        
        cell.lblLastMessage.text = inbox.text
        if (inbox.receiverPic.count != 0) {
            cell.imgProfile.af_setImage(withURL: URL.init(string: inbox.receiverPic)!)
            cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height/2.0
            cell.imgProfile.layer.masksToBounds = true
        }
        cell.lblCount.layer.cornerRadius = cell.lblCount.frame.size.height/2
        cell.lblCount.layer.masksToBounds = true
        
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
        let obj:ConversationViewController = self.storyboard?.instantiateViewController(withIdentifier: "conversationView") as! ConversationViewController
        obj.objUser = store
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
}
