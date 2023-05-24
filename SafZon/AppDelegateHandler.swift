//
//  AppDelegateHandler.swift
//  SafZon
//
//  Created by I MADE DWI MAHARDIKA on 24/05/23.
//

import UserNotifications
import UIKit

class AppDelegateHandler: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else {
                print("Notification authorization denied")
            }
        }
        return true
    }
    
    // Implement any other AppDelegate methods if needed
    
    // Handle receiving notifications while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Customize the presentation options as needed
        completionHandler([.alert, .sound])
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save any relevant data or state
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Restore any saved data or state
    }
    
}
