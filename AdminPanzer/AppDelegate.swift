//
//  AppDelegate.swift
//  AdminPanzer
//
//  Created by Panzer Tech Pte Ltd on 17/12/19.
//  Copyright © 2019 test.com. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import Alamofire

let kLastClosedDate = "LastClosedDate"
 var net = NetworkReachabilityManager()
//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , MessagingDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AppDelegate.applicationDidTimeout(notification:)),
                                               name: .appTimeout,
                                               object: nil
        )
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        self.setUpFirebaseMessaging(application: application)
        
        self.addNetworkReachability()
        return true
    }
    @objc func networkStatusChanged(_ notification: Notification) {
        // Do something globally here!
    }
    func addNetworkReachability(){
        
        
        
       
            net?.startListening(onUpdatePerforming: { (status) in
               
                    switch status {
                        
                    case .reachable(.ethernetOrWiFi):
                        print("The network is reachable over the WiFi connection")
                        if isNoNetAlertShown == true{
                  self.window?.rootViewController!.networkConnected()
                        }
                    case .notReachable:
                        print("The network is not reachable")
                         self.window?.rootViewController!.showNoNetwork()
                    case .unknown :
                        print("It is unknown whether the network is reachable")
                        
                    case .reachable(.cellular):
                         print("It is cellular")
                         if isNoNetAlertShown == true{
                            self.window?.rootViewController!.networkConnected()
                        }
                    }
            })
 
        
    }
    
    func setLogin(){
        if Auth.auth().currentUser != nil{
            do {
                try Auth.auth().signOut()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInNav = storyboard.instantiateViewController(withIdentifier: "MainNavigation") as! UINavigationController
        self.window?.rootViewController = signInNav
    }
    @objc func applicationDidTimeout(notification: NSNotification) {
        
        if Auth.auth().currentUser != nil && isSignedIn == true{
            if self.window?.rootViewController is UINavigationController{
               
            }
            if isSessionTimeoutAlertShown == false{
            self.window?.rootViewController!.showSessionTimeOut()
            }
        }
        
    }
    //MARK: Session TimeOut
    func checkSessionTimeOut(){
        let lastDate = UserDefaults.standard.object(forKey: kLastClosedDate)
        if lastDate != nil{
            let timeDiff = Date().timeIntervalSince(lastDate! as! Date)
            if timeDiff > 100{
                if Auth.auth().currentUser != nil && isSignedIn == true{
                     if isSessionTimeoutAlertShown == false{
                    self.window?.rootViewController!.showSessionTimeOut()
                    }
                }
            }
            UserDefaults.standard.removeObject(forKey: kLastClosedDate)
        }
      
    }
    //MARK: Firebase Messaging
    func setUpFirebaseMessaging(application: UIApplication){
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to auth
        Messaging.messaging().apnsToken = deviceToken
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
        
        // Further handling of the device token if needed by the app
        // ...
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
     
        
        // Print full message.
        print(notification)
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        // This notification is not auth related, developer should handle it.
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UserDefaults.standard.set(Date(), forKey: kLastClosedDate)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        checkSessionTimeOut()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
         if Auth.auth().currentUser != nil{
            do {
                try Auth.auth().signOut()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AdminPanzer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

