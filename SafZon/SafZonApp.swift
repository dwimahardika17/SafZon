//
//  SafZonApp.swift
//  SafZon
//
//  Created by I MADE DWI MAHARDIKA on 24/05/23.
//

import SwiftUI
import FirebaseCore
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
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

@main
struct SafZonApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var coreDataStack = CoreDataStack()
//    @UIApplicationDelegateAdaptor(AppDelegateHandler.self) var appDelegate
//    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            CekSignUp()
                .environmentObject(AuthViewModel())
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
