//
//  AppDelegate.swift
//  SlothParty
//
//  Created by Massimo Maddaluno on 05/05/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NSLog("Application launched")
         application.registerForRemoteNotifications()
        
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //MARK: Background & Push Notifications
//     func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: () -> Void) {
//
//        if application.applicationState == .inactive {
//            // Do nothing
//        }
//        let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
//        let container = CloudDBController.shared.container
//        let publicDB = CloudDBController.shared.publicDB
//
//        if notification!.notificationType == .query {
//            let queryNotification = notification!
//            if queryNotification.queryNotificationReason  == .recordUpdated {
//                print("queryNotification.recordID \(queryNotification.recordID)")
//                print(queryNotification.recordFields)
//            }
//        }
//        print("userInfo \(userInfo)")
//    }
//

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
                if application.applicationState == .inactive {
                    // Do nothing
                }
                let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
                let container = CloudDBController.shared.container
                let publicDB = CloudDBController.shared.publicDB
        
                if notification!.notificationType == .query {
                    let queryNotification = notification!
                    if queryNotification.queryNotificationReason  == .recordUpdated {
                        print("queryNotification.recordID \(queryNotification.recordID)")
                        print(queryNotification.recordFields)
                    }
                }
                print("userInfo \(userInfo)")
    }
}

