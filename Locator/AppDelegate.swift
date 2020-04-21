//
//  AppDelegate.swift
//  Locator
//
//  Created by Simran Bhattarai on 2020-04-11.
//  Copyright © 2020 Simran Bhattarai. All rights reserved.
//
import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
    
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
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken=deviceToken
        
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
    
    

}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")

        // Print full message.
        print("%@", userInfo)

    }

}

extension AppDelegate : MessagingDelegate {
// Receive data message on iOS 10 devices.
func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
    print("%@", remoteMessage.appData)
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
      print(fcmToken)
        makePostCall(fcmToken)
    }
    
    //POST Method
    func makePostCall(_ token: String) {
      let todosEndpoint: String = "http://www.aisarhan.com/CoronaAPI/api/NotificationController/AddDeviceToken"
      guard let todosURL = URL(string: todosEndpoint) else {
        print("Error: cannot create URL")
        return
      }
      var todosUrlRequest = URLRequest(url: todosURL)
      todosUrlRequest.httpMethod = "POST"
        todosUrlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-type")
      let newTodo: [String: String] = ["deviceId":"1234", "tokenId": token]
      let jsonTodo: Data
      do {
        jsonTodo = try JSONSerialization.data(withJSONObject: newTodo, options: [])
        todosUrlRequest.httpBody = jsonTodo
       // print("JsonTodo")
       print(String(decoding:jsonTodo, as:UTF8.self))
      } catch {
        print("Error: cannot create JSON from todo")
        return
      }

      let session = URLSession.shared

      let task = session.dataTask(with: todosUrlRequest) {
        (data, response, error) in
        guard error == nil else {
          print("error calling POST on /todos/1")
          print(error!)
          return
        }
       
        guard let responseData = data else {
          print("Error: did not receive data")
          return
        }
        print("responseData",String(decoding:responseData, as:UTF8.self))

      }
      task.resume()
    }
}
import Foundation

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
