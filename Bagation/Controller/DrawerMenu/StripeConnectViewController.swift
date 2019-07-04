//
//  StripeConnectViewController.swift
//  Bagation
//
//  Created by vivek soni on 28/03/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import WebKit
class StripeConnectViewController: UIViewController {

    @IBOutlet weak var webview: WKWebView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    //replace this with your Heroku hosted Node.js App url
   // let strURL = String(format:"%@",Constants.stripClient)
    
    let url = URL(string: "https://connect.stripe.com/oauth/authorize?response_type=code&scope=read_write&client_id=\(Constants.stripClientId)")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorView.isHidden = true
        
        
        guard let url = self.url else {
            self.alert(message: "The URL seems to be Invalid.")
            return
        }
        
        //let path: String = "/authorize"
        //.appendingPathComponent(path)
        let cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        let timeout: TimeInterval = 6.0
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        
        request.httpMethod = "GET"
        
        activityIndicatorView.isHidden = false
        webview.load(request)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation, withError error: NSError) {
        activityIndicatorView.startAnimating()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation, withError error: NSError) {
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
        //self.alert(message: error.localizedDescription)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation, withError error: NSError) {
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        if let url = navigationAction.request.url {
            
            if let urlComponents = URLComponents(string: url.absoluteString) {
                print("strip url data",urlComponents.queryItems ?? "")
                if let queryString = urlComponents.queryItems {
                    for query in queryString {
                        if query.name == "code" {
                            if let value = query.value {
                                print("Stripe Code Authentication = \(value)")
                                self.CallApiForAuthentication(codeToken: value)
                                
                            }
                        }
                        if query.name == "stripe_user_id" {
                            if let value = query.value {
                                
                                //If authentication to your Stripe Account was successful, the Stripe User ID will be returned as a query string in the variable 'value'.  You can then proceed to save it to your application’s database, to use at a later stage for any subsequent Stripe connection requests.
                                
                                print("Stripe User ID = \(value)")
                            }
                        }
                    }
                }
            }
        }
        decisionHandler(.allow)
    }

//    func webViewDidStartLoad(_ webView: UIWebView) {
//        activityIndicatorView.startAnimating()
//    }
//    
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        activityIndicatorView.isHidden = true
//        activityIndicatorView.stopAnimating()
//    }
//    
//    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
//        activityIndicatorView.isHidden = true
//        activityIndicatorView.stopAnimating()
//        //self.alert(message: error.localizedDescription)
//    }
//    
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        if let url = request.url {
//            
//            if let urlComponents = URLComponents(string: url.absoluteString) {
//                print("strip url data",urlComponents.queryItems ?? "")
//                if let queryString = urlComponents.queryItems {
//                    for query in queryString {
//                        if query.name == "code" {
//                            if let value = query.value {
//                                print("Stripe Code Authentication = \(value)")
//                                self.CallApiForAuthentication(codeToken: value)
//                                
//                            }
//                        }
//                        if query.name == "stripe_user_id" {
//                            if let value = query.value {
//                                
//                                //If authentication to your Stripe Account was successful, the Stripe User ID will be returned as a query string in the variable 'value'.  You can then proceed to save it to your application’s database, to use at a later stage for any subsequent Stripe connection requests.
//                                
//                                print("Stripe User ID = \(value)")
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        
//        return true
//    }
//    
    func alert(message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(action)
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func CallApiForAuthentication(codeToken:String) {
        Utility.showHUD(msg: "")
        
        let value = ["client_secret": Constants.stripSecretKey , "code":codeToken, "grant_type":"authorization_code"]
        print(value)
        APIManager.postRequestWith(strURL: "token", Param: value) { (Dict, Error) in
            Utility.hideHUD()
            if Error == nil {
                if let valuedict = Dict {
                    print(valuedict)
                    if (valuedict.object(forKey: "stripe_user_id") != nil){
                        self.CallApiForStripeAccount(stripeId: valuedict.object(forKey: "stripe_user_id") as! String)
                    } else {
                        if (valuedict.object(forKey: "error_description") != nil){
                             self.showAlert(strMessage: valuedict.object(forKey: "error_description") as! String)
                        }
                    }
                    //self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.showAlert(strMessage: "")
            }
        }
    }
    
    
    func CallApiForStripeAccount(stripeId:String) {
        Utility.showHUD(msg: "")
        
        let value = ["userid":User.shared.userId,"baghandlerID":"0","StripAccountID": stripeId]
        
        APIManager.getRequestWith(strURL: Constants.requestStripAccountId, Param: value) { (Dict, Error) in
            Utility.hideHUD()
            if Error == nil {
                if let value = Dict {
                    print(value)
                    SharedProperties.objDefault.setValue("\(stripeId)", forKey: "StripAccountID")
                    self.navigationController?.popViewController(animated: true)
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
