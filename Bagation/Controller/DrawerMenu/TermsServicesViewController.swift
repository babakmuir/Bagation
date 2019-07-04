//
//  TermsServicesViewController.swift
//  Bagation
//
//  Created by vivek soni on 25/12/17.
//  Copyright © 2017 IOSAppExpertise. All rights reserved.
//

import UIKit
import WebKit
import InteractiveSideMenu

class TermsServicesViewController: UIViewController,SideMenuItemContent {
    @IBOutlet weak var webView               : WKWebView!
    
    var comingFor : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (User.shared.userType.count != 0) {
            if (User.shared.userType == "2") {
                if let pdf = Bundle.main.url(forResource: "Terms and Conditions Bag Handler - 06.4.18", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                    let req = NSURLRequest(url: pdf)
                    webView.load(req as URLRequest)
                }
            } else {
                if let pdf = Bundle.main.url(forResource: "Terms and Conditions User - 06.4.18", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                    let req = NSURLRequest(url: pdf)
                    webView.load(req as URLRequest)
                }
            }
        } else {
            if (comingFor == "2") {
                if let pdf = Bundle.main.url(forResource: "Terms and Conditions Bag Handler - 06.4.18", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                    let req = NSURLRequest(url: pdf)
                    webView.load(req as URLRequest)
                }
            } else {
                if let pdf = Bundle.main.url(forResource: "Terms and Conditions User - 06.4.18", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                    let req = NSURLRequest(url: pdf)
                    webView.load(req as URLRequest)
                }
            }
        }
        
        
       /* let strURL = String(format: "%@", "https://www.google.com/policies/terms/")
        let escapedAddress = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(fileURLWithPath: escapedAddress!)
        //            let req = NSURLRequest(url:url)
        do {
            let data = try Data(contentsOf: url)
            webView.load(data, mimeType: "application/pdf", textEncodingName:"", baseURL: url.deletingLastPathComponent())
        }
        catch {
            // catch errors here
        }*/
       
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
