//
//  PushNotification.swift
//  Locator
//
//  Created by Simran Bhattarai on 2020-04-14.
//  Copyright © 2020 Simran Bhattarai. All rights reserved.
//
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    let userID: String
    init(userID: String) {
        self.userID = userID
        super.init()
    }
    
    
    func registerForPushNotifications() {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            let usersRef = Firestore.firestore().collection("users_table").document(userID)
            usersRef.setData(["fcmToken": token])
            print("Token:", token)
        }
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        updateFirestorePushTokenIfNeeded()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            print("Remote instance ID token: \(result.token)")
            self.makePostCall(result.token)
          }
           
        }
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        // Process notification content
        print("\(content.userInfo)")
        completionHandler([.alert, .sound]) // Display notification Banner

    }
    
        //POST Method
           func makePostCall(_ token: String) {
            guard let deviceid = UIDevice.current.identifierForVendor?.uuidString else { return }
               print("Token:", token)
             let todosEndpoint: String = "http://www.aisarhan.com/CoronaAPI/api/NotificationController/AddDeviceToken"
             guard let todosURL = URL(string: todosEndpoint) else {
               print("Error: cannot create URL")
               return
             }
             var todosUrlRequest = URLRequest(url: todosURL)
             todosUrlRequest.httpMethod = "POST"
               todosUrlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-type")
             let newTodo: [String: String] = ["deviceId":deviceid, "tokenId": token]
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
               print("responseDatatoken",String(decoding:responseData, as:UTF8.self))
    
             }
             task.resume()
           }
}
