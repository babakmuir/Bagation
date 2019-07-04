//
//  TermsAndPrivacyViewController.swift
//  Bagation
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import WebKit
class TermsAndPrivacyViewController: UIViewController {
    let txtViewTravel = UITextView()
    let txtViewBagHanlder = UITextView()
    @IBOutlet weak var webView               : WKWebView!
    let strType = String ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if (User.shared.userType == "2") {
            if let pdf = Bundle.main.url(forResource: "Terms and Conditions Bag Handler - 06.4.18", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                let req = NSURLRequest(url: pdf)
                webView.load(req as URLRequest)
            }
        } else  if (User.shared.userType == "1") {
            if let pdf = Bundle.main.url(forResource: "Terms and Conditions User - 06.4.18", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                let req = NSURLRequest(url: pdf)
                webView.load(req as URLRequest)
            }
        } else {
            let alert = UIAlertController(title: "Alert", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Yes", style: .default) { (alertAction) in
            }
            alert.addAction(action)
            self.present(alert, animated:true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func closeMenu(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        webView.scrollView.contentInset = .zero;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonAgreeAction(_ sender: UIButton) {
        let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let notificationViewController = storyBoard.instantiateViewController(withIdentifier: "notificationView")
        self.present(notificationViewController, animated: true, completion: nil)
       
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
