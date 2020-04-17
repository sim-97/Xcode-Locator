//
//  ViewController.swift
//  Locator
//
//  Created by Simran Bhattarai on 2020-04-11.
//  Copyright © 2020 Simran Bhattarai. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude)",",","\(locValue.longitude)")
        let locationstring = String(locValue.latitude)+","+String(locValue.longitude)
        print(type(of: locationstring), locationstring)
        makePostCall()
    }
            

    
    @IBAction func updateDiagnosis(_ sender: Any) {
        let dialogMessage = UIAlertController(title: "Confirm", message: "Would you like to update your diagnosis to positive?", preferredStyle: .alert)
        // Create OK button with action handler
               let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    print("Ok button tapped")
                self.makePutCall()
                    
               })
               
               // Create Cancel button with action handlder
               let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                   print("Cancel button tapped")
               }
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
        
    }
    
    //GET Method
    func makeGetCall() {
      // Set up the URL request
      let todoEndpoint: String = "http://www.aisarhan.com/CoronaAPI/api/GeoTrackerController/WelcomeMessage"
      guard let url = URL(string: todoEndpoint) else {
        print("Error: cannot create URL")
        return
      }
      let urlRequest = URLRequest(url: url)

      // set up the session
      let config = URLSessionConfiguration.default
      let session = URLSession(configuration: config)

      // make the request
      let task = session.dataTask(with: urlRequest) {
        (data, response, error) in
        // check for any errors
        guard error == nil else {
          print("error calling GET on /todos/1")
          print(error!)
          return
        }
        // make sure we got data
        guard let responseData = data else {
          print("Error: did not receive data")
          return
        }
     
        print("responseData",String(decoding:responseData, as:UTF8.self))
        // parse the result as JSON, since that's what the API provides
        do {
          guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
            as? [String: Any] else {
                print(responseData)
              return
          }
          // now we have the todo
          // let's just print it to prove we can access it
          print("The todo is: " + todo.description)

          // the todo object is a dictionary
          // so we just access the title using the "title" key
          // so check for a title and print it if we have one
          guard let todoTitle = todo["title"] as? String else {
            print("Could not get todo title from JSON")
            return
          }
          print("The title is: " + todoTitle)
        } catch  {
          print("error trying to convert data to JSON")
          return
        }
      }
      task.resume()
    }
    //POST Method
    func makePostCall() {
      let todosEndpoint: String = "http://www.aisarhan.com/CoronaAPI/api/GeoTrackerController/StoreUseLoction"
      guard let todosURL = URL(string: todosEndpoint) else {
        print("Error: cannot create URL")
        return
      }
      var todosUrlRequest = URLRequest(url: todosURL)
      todosUrlRequest.httpMethod = "POST"
        todosUrlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-type")
      let newTodo: [String: String] = ["deviceid":"1234", "location": "test", "locationdate": "5-20-2020"]
      let jsonTodo: Data
      do {
        jsonTodo = try JSONSerialization.data(withJSONObject: newTodo, options: [])
        todosUrlRequest.httpBody = jsonTodo
        print("JsonTodo")
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
    //PUT Call
    func makePutCall() {
      let todosEndpoint: String = "http://www.aisarhan.com/CoronaAPI/api/NotificationController/NotifyCorona"
      guard let todosURL = URL(string: todosEndpoint) else {
        print("Error: cannot create URL")
        return
      }
      var todosUrlRequest = URLRequest(url: todosURL)
      todosUrlRequest.httpMethod = "PUT"
        todosUrlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-type")
      let newTodo: [String: Any] = ["deviceid":"1234", "hasCorona": 1]
      let jsonTodo: Data
      do {
        jsonTodo = try JSONSerialization.data(withJSONObject: newTodo, options: [])
        todosUrlRequest.httpBody = jsonTodo
        print("JsonTodo")
        print(String(decoding:jsonTodo, as:UTF8.self))
      } catch {
        print("Error: cannot create JSON from todo")
        return
      }

      let session = URLSession.shared

      let task = session.dataTask(with: todosUrlRequest) {
        (data, response, error) in
        guard error == nil else {
          print("error calling PUT on /todos/1")
          print(error!)
          return
        }
       
        guard let responseData = data else {
          print("Error: did not receive data")
          return
        }
         print("responseDataPUT",String(decoding:responseData, as:UTF8.self))

      }
      task.resume()
    }
    
    
    
}



