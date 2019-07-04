//
//  Constants.swift
//  PigeonShip
//
//  Created by Vivek on 22/09/1938 Saka.
//  Copyright © PigeonShip Inc. All rights reserved.
//
import Foundation
import UIKit

enum AppMode {
    case Traveller
    case BagHandler
    init(value: Int) {
        switch value {
        case 1:
            self = .Traveller
        default:
            self = .BagHandler
        }
    }
}

class Constants {

    // Userdefault
    static let objDefault = UserDefaults.standard
    
    // MARK: - Base URL
    //static let baseURLLocal = "http://services.iosappexpertise.com/BagationService.svc/"
    // static let baseURLLocal = "http://192.168.1.100/BagationService/BagationService.svc/"
   //Live
   static let baseURLLocal = "http://bagationservice-prod.ap-southeast-2.elasticbeanstalk.com/BagationService.svc/"
    
    static let baseURLGoogle = "https://maps.googleapis.com/maps/api/"
    //Test Mode
    //static let stripClientId = "ca_Ccf1XzlsG1rQeNIGgudbO12gOYMlwaAh"
    static let stripPublisherKey = "pk_live_75tyRWHj4Fb8w8vtUprESiAo"//"pk_test_SfAvR2utsPqy7VEoKTwYdVNr"
    static let stripSecretKey = "sk_live_76nkILcrwyV54RAbOil8zybO" //"sk_test_npxvqxw1b7kaLyz8Ewie4aJc"
    
    //Live
    static let stripClientId = "ca_EMXslNpKJu836GrzvWzhRo46HY8G9HGL"
//    static let stripPublisherKey = "pk_live_ZWewLdtEqU61yXuJaC6CCrup"
//    static let stripSecretKey = "sk_live_8c4uWsjjyS5CE2PoT96wepu1"
    
    static let URL_SendNotification   =   "https://fcm.googleapis.com/fcm/send"
    static let FCM_Server_Key         =   "key=AIzaSyD5dXFOaYqt08obFgsO3pVeGQkClg_VaWw"
    
    // MARK: - API
    static let requestAPILogin = "AuthenticateUserLogin"
    static let requestAPISignUP = "InsertUserDetail"
    static let requestAPISearch = "GetAllAddresses"
    static let requestAPIGoogle = "geocode/json"
    static let firebaseUserAPI = "ManageUserFirBaseDetail"
    static let requestAPIOrderDetails = "GetAllOrderDetails"
    static let requestAPICalender = "GetAllOrderDetailsByBagHandlerID"
    static let requestAPIReleaseSpace = "ReleaseOrderHistory"
    static let requestForgotPassword = "InsertResetPassword"
    static let requestPlaceOrder = "InsertOrderDetailGet"
    static let getStorageSpace = "GetStorageSpace"
    static let requestuploadUserPicture = "UploadProfilePhotoNew"
    static let requestClientToken = "GetPaymentClientToken"
    static let requestClientNonce = "ProcessPayment"
    static let requestStripAccountId = "SaveBaghandlerStripeAccID"
    static let kGooglePlaceKey = "AIzaSyAmei0r8RqAed78sBFphfPs5VVRHVXspmE"
    //static let kGooglePlaceKey = "AIzaSyBEBTGnUYpLn5mm2dcFZUMTCmCcmyNTb44"
    
    static let pushKey = "fad2d4d3b2b8c494723997bd94b2ac267f22fcc2c77844f4866e2c31c130d55f"
    // MARK: - Request Identifier
    static let PushNotificationIdentifier: String = "RequestNotificationIdentifier"
    static let PushNavigationIdentifier: String = "NavigationIdentifier"
    static let LaunchPushIdentifier: String = "LaunchPushIdentifier"
    static let LogoutIdentifier: String = "LogoutNavigationIdentifier"

    // MARK: - Segue Identifier
    static let SegueSignup: String = "Segue_Signup"
    static let SegueLoginHome: String = "SegueLoginHome"
    static let SegueSignupLogin: String = "SegueSignupLogin"
    
    
    // MARK: - UserDefaults Identifier
    static let key_UserDeviceToken = "userDeviceToken"
    static let key_UserToken = "userSession"
    static let key_UserID = "userID"
    static let Key_UserData = "UserData"
    static let Key_UserLogggedIn = "userloggedin"
    static let Key_UserLogggedInType = "userloggedinType"
    static let Key_IsUserLoggedIn = "IsUserLogin"
    static let Key_SavedStatus = "SavedStatus"
    static let Key_DetailView = "DetailView"
    static let Key_DeviceToken = "DeviceToken"
    static let Key_UserLastLocation = "UserLocation"
    static let Key_UserLastCity = "UserCity"
    static let Key_UserProfilePic = "ProfilePicture"

    static let screenSize =  UIScreen.main.bounds
    
    // MARK: - Storyboard Identifier
    static let ID_Notification: String = "notificationVC"
    static let ID_OnboardingView: String = "onboardingView"
    
    // MARK: - Constant Variable
    static let pageSize: String = "20"
    static let kClientID: String = "951997558400-p1pftbi5csrailomq3g1euiqchdv9q42.apps.googleusercontent.com"

    
    // MARK: - Static Messages

    static let errorMessage: String = "Something went wrong, Please try again."
    static let errorNetworkMessage:String = "No Network found, Please try again."
    
    // MARK: - User Interface
    static let primaryColor: UIColor = UIColor.init(red: 123.0/255.0, green: 123.0/255.0, blue: 123.0/255.0, alpha: 1.0)
    static let themeColor: UIColor = UIColor.init(red: 207.0/255.0, green: 207.0/255.0, blue: 207.0/255.0, alpha: 1.0)
    static let themeBlueColor: UIColor = UIColor.init(red: 68.0/255.0, green: 184.0/255.0, blue: 225.0/255.0, alpha: 1.0)
    
    static let whiteColor: UIColor = UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let RedColor: UIColor = UIColor.red
    static let BlueColor: UIColor = UIColor.blue
    static let GreenColor: UIColor = UIColor.green
    
    static let eventColor1: UIColor = UIColor.init(red: 76.0/255.0, green: 219.0/255.0, blue: 170.0/255.0, alpha: 1.0)

    static let eventColor2: UIColor = UIColor.init(red: 190.0/255.0, green: 49.0/255.0, blue: 175.0/255.0, alpha: 1.0)

    static let ScreenWidth  =  UIScreen.main.bounds.size.width
    
    static let  defaultMessageBubbleTextInViewMaxWidth : CGFloat = Constants.ScreenWidth*0.55
     static let SecondsInYear: TimeInterval = 31536000
     static let SecondsInLeapYear: TimeInterval = 31622400
     static let SecondsInMonth28: TimeInterval = 2419200
     static let SecondsInMonth29: TimeInterval = 2505600
     static let SecondsInMonth30: TimeInterval = 2592000
     static let SecondsInMonth31: TimeInterval = 2678400
     static let SecondsInWeek: TimeInterval = 604800
     static let SecondsInDay: TimeInterval = 86400
     static let SecondsInHour: TimeInterval = 3600
     static let SecondsInMinute: TimeInterval = 60
     static let MillisecondsInDay: TimeInterval = 86400000
    
     static let AllCalendarUnitFlags: Set<Calendar.Component> = [.year, .quarter, .month, .weekOfYear, .weekOfMonth, .day, .hour, .minute, .second, .era, .weekday, .weekdayOrdinal, .weekOfYear]
    
}


