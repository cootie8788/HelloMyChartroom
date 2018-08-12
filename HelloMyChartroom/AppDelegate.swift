//
//  AppDelegate.swift
//  HelloMyChartroom
//
//  Created by 林沂諺 on 2018/6/27.
//  Copyright © 2018年 AppleCode. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Ask user‘s premission
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (grant, error) in
            if let error = error {
                print("requestAuthorization fail: \(error)")
            }
            print("User grant the permission:" + (grant ? "Yes":"NO"))
        }
        //要求 device token
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Convert deviceToken to String
//        let deviceTokenString = deviceToken.map { (byte) -> String in
//            return String(format: "%02x", byte)
//        }.joined()
//        let deviceTokenString = deviceToken.map { (byte) -> String in
//             String(format: "%02x", byte)
//            }.joined()
        let deviceTokenString = deviceToken.map {String(format: "%02x", $0)
            }.joined()
        print("deviceTokenString: \(deviceTokenString)")
        Commnuicator.shared.updateDeviceToken((deviceTokenString)) { (error, result) in
            if let error = error  {
            print("updateDeviceToken fail: \(error)")
            return
            }else if let result = result {
                print("updateDeviceToken Ok: \(result)")
            }
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(" didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification: \(userInfo)")
        NotificationCenter.default.post(name: .didReceiveRemoteMessage, object: nil)
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

  
}

