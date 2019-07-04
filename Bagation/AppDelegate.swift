//
//  AppDelegate.swift
//  Bagation
//
//  Created by vivek soni on 28/12/17.
//  Copyright © 2017 IOSAppExpertise. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire
import GoogleSignIn
import GoogleToolboxForMac
import FacebookCore
import FacebookLogin
import GTMOAuth2
import UserNotifications
import Firebase
import GooglePlaces
import GoogleMaps
import Stripe
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var objAppDelegate:AppDelegate!
    var currentLat :CLLocationDegrees! = 0.0
    var currentLong :CLLocationDegrees! = 0.0
    var currentCity :String = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.objAppDelegate = self
        Fabric.with([STPAPIClient.self, Crashlytics.self])

        FirebaseApp.configure()
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // [START set_messaging_delegate]
            //Messaging.messaging().delegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        //Stripe Configuration
        STPPaymentConfiguration.shared().publishableKey = Constants.stripPublisherKey
        
        getCurrentLocationDetail()
       
        // configure Google
        GIDSignIn.sharedInstance().clientID = Constants.kClientID
        if SharedProperties.checkLoggedIn() {
            self.setHomeRootView()
        }
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = Constants.whiteColor
        navigationBarAppearace.barTintColor = Constants.themeBlueColor
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        GMSPlacesClient.provideAPIKey(Constants.kGooglePlaceKey)
        GMSServices.provideAPIKey(Constants.kGooglePlaceKey)

        // Override point for customization after application launch.
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
        
        print("Token is here   \(String(describing: Messaging.messaging().fcmToken))")
        print("Token is here   \(String(describing: Messaging.messaging().apnsToken))")
      
        if UserDefaults.standard.object(forKey: Constants.Key_DeviceToken) == nil
        {
            UserDefaults.standard.set(Messaging.messaging().fcmToken, forKey: Constants.Key_DeviceToken)
        }
        else
        {
            let fcmSavedToken = UserDefaults.standard.value(forKey: Constants.Key_DeviceToken) as! String
            if fcmSavedToken == Messaging.messaging().fcmToken
            {
                
            }
            else
            {
                UserDefaults.standard.set(Messaging.messaging().fcmToken, forKey: Constants.Key_DeviceToken)
            }
        }
        if (Messaging.messaging().fcmToken != nil) {
            UIPasteboard.general.string = Messaging.messaging().fcmToken
        }
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: - Notifications
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
            
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        Constants.objDefault.set(fcmToken, forKey: Constants.Key_DeviceToken)
        UIPasteboard.general.string = fcmToken
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
        //self.setHomeRootView()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
        
    }
    
    // MARK: - Methods
    func setHomeRootView () {
        User.shared.loadUser()
        SharedProperties.objDefault.set(User.shared.userType, forKey: "userType")
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        let storyBoard :UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController:HostViewController = storyBoard.instantiateViewController(withIdentifier: "hostView") as! HostViewController
        if (SharedProperties.objDefault.value(forKey: Constants.Key_UserLogggedInType) != nil) {
            let userType = SharedProperties.objDefault.value(forKey: Constants.Key_UserLogggedInType) as! String
            homeViewController.userType = userType
            let nav = UINavigationController(rootViewController: homeViewController)
            // Make it a root controller
            self.window!.rootViewController = nav
            self.window?.makeKeyAndVisible()
        } else {
            self.signOut()
        }
    }
    
    func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    func signOut () {
        
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        self.getCurrentLocationDetail()
        Constants.objDefault.removeObject(forKey:  Constants.Key_UserProfilePic)
        SharedProperties.setLoggedOut()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // [START set_messaging_delegate]
            Messaging.messaging().delegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        
        let navigationController: UINavigationController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navigationId") as? UINavigationController
        // Make it a root controller
        self.window!.rootViewController = navigationController
        self.window!.backgroundColor = UIColor.white
        FireBaseManager.sharedInstance.updateChatStatusForUser(statusValue: "false")
        FireBaseManager.sharedInstance.logoutUser()
    }
    
    func restoreLocation() {
        let dic: NSDictionary = ["lat":self.currentLat,"long":self.currentLong]
        UserDefaults.standard.set(dic, forKey: Constants.Key_UserLastLocation)
        UserDefaults.standard.synchronize()
        
        UserDefaults.standard.set(self.currentCity, forKey: Constants.Key_UserLastCity)
        UserDefaults.standard.synchronize()
    }
    
    func getCurrentLocationDetail(){
        
        LocationManager.sharedInstance.getCurrentReverseGeoCodedLocation { (location, placemark, error) in
            if error == nil {
                print()
                
                guard let lat = location?.coordinate.latitude else {
                    return
                }
                self.currentLat = lat
                guard let lon = location?.coordinate.longitude else {
                    return
                }
                self.currentLong = lon
                
                 let dic: NSDictionary = ["lat":location?.coordinate.latitude ?? "","long":location?.coordinate.longitude ?? ""]
                
                UserDefaults.standard.set(dic, forKey: Constants.Key_UserLastLocation)
                UserDefaults.standard.synchronize()
                guard let city:String = placemark?.addressDictionary! ["City"] as? String else {
                    return
                }
                self.currentCity = city
                
                UserDefaults.standard.set(city, forKey: Constants.Key_UserLastCity)
                UserDefaults.standard.synchronize()
                
               // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "searchNearByAPI"), object: nil)
                
            } else {
                
            }
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
         FireBaseManager.sharedInstance.updateChatStatusForUser(statusValue: "false")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        FireBaseManager.sharedInstance.updateChatStatusForUser(statusValue: "false")
        
        let timerDict:[String: Bool] = ["TimerStatus": false]
        NotificationCenter.default.post(name: NSNotification.Name.init("update_load_timer"), object: nil, userInfo: timerDict)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        FireBaseManager.sharedInstance.updateChatStatusForUser(statusValue: "true")
        
        let timerDict:[String: Bool] = ["TimerStatus": true]
        NotificationCenter.default.post(name: NSNotification.Name.init("update_load_timer"), object: nil, userInfo: timerDict)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FireBaseManager.sharedInstance.updateChatStatusForUser(statusValue: "true")
        
        //let timerDict:[String: Bool] = ["TimerStatus": true]
        //NotificationCenter.default.post(name: NSNotification.Name.init("update_load_timer"), object: nil, userInfo: timerDict)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        FireBaseManager.sharedInstance.updateChatStatusForUser(statusValue: "false")
    }
    
   

    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        let facebook = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        
        let google = GIDSignIn.sharedInstance().handle(url,
                                                       sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                       annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return facebook || google
    }

}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
         print("Message User info: \(userInfo)")
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
    
}
// [END ios_10_message_handling]
extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        print("Received Remote Message: 1\nCheck Out:\n")
        
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        print("Received Remote Message: 2\nCheck Out:\n")
    }
    
    
    
    
    // Receive data message on iOS 10 devices while app is in the foreground.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("Received Remote Message: 3\nCheck In:\n")
        debugPrint(remoteMessage.appData)
        print("Received Remote Message: 3\nCheck Out:\n")
        
    }
    // [END ios_10_data_message]
}

