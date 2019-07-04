//
//  TutorialViewController.swift
//  Bagation
//
//  Created by vivek soni on 31/12/17.
//  Copyright © 2017 IOSAppExpertise. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIScrollViewDelegate {
    var pageControl                                     = PageControl()
    @IBOutlet weak var viewPageControl                  : UIView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //1
        self.scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        //let scrollViewWidth:CGFloat = self.scrollView.frame.width
        //let scrollViewHeight:CGFloat = self.scrollView.frame.height
       
        //3
//        let imgOne = UIImageView(frame: CGRect(x:0, y:0,width:scrollViewWidth, height:scrollViewHeight))
//        imgOne.image = UIImage(named: "Slide 1")
//        let imgTwo = UIImageView(frame: CGRect(x:scrollViewWidth, y:0,width:scrollViewWidth, height:scrollViewHeight))
//        imgTwo.image = UIImage(named: "Slide 2")
//        let imgThree = UIImageView(frame: CGRect(x:scrollViewWidth*2, y:0,width:scrollViewWidth, height:scrollViewHeight))
//        imgThree.image = UIImage(named: "Slide 3")
//        let imgFour = UIImageView(frame: CGRect(x:scrollViewWidth*3, y:0,width:scrollViewWidth, height:scrollViewHeight))
//        imgFour.image = UIImage(named: "Slide 4")
//        
//        self.scrollView.addSubview(imgOne)
//        self.scrollView.addSubview(imgTwo)
//        self.scrollView.addSubview(imgThree)
//        self.scrollView.addSubview(imgFour)
        //4
        
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * 3, height:self.scrollView.frame.height)
        self.scrollView.delegate = self
        
        self.preparePageControl()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnBecomeTraveller(_ sender: Any) {
        let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let dashboardViewController = storyBoard.instantiateViewController(withIdentifier: "dashboard") as! DashboardViewController
        dashboardViewController.appMode = "1"  //Traveller
        self.present(dashboardViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnBecomeBagHandler(_ sender: Any) {
        let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let dashboardViewController = storyBoard.instantiateViewController(withIdentifier: "dashboard") as! DashboardViewController
        dashboardViewController.appMode = "2"  //BagHandler
        self.present(dashboardViewController, animated: true, completion: nil)
    }
    
    func preparePageControl() {
        viewPageControl.backgroundColor = UIColor.clear
        pageControl.isUserInteractionEnabled = false
        pageControl.dotColorCurrentPage = Constants.primaryColor
        pageControl.dotColorOtherPage = Constants.themeColor
        self.pageControl.numberOfPages = 3
        self.pageControl.frame = self.viewPageControl.bounds
        self.pageControl.currentPage = 0
        self.viewPageControl.addSubview(self.pageControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        // Change the text accordingly
        if Int(currentPage) == 0 {
            // Show the "Let's Start" button in the last slide (with a fade in animation)                     
            
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                 self.lblSubTitle.text = "locate, drop and explore"
            })
           
        } else if Int(currentPage) == 1{
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                self.lblSubTitle.text = "locate, drop and explore"
            })
            
        } else {
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                self.lblSubTitle.text = "locate, drop and explore"
            })
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
