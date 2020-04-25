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
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var infected = 0
    let defaults = UserDefaults.standard
    

    @IBOutlet weak var instructions: UITextView!
    @IBOutlet weak var infectedButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if defaults.bool(forKey: "termsAccepted")==true{
            print("Second")
            if CLLocationManager.authorizationStatus() != .authorizedAlways     // Check authorization for location tracking
            {
                locationManager.requestAlwaysAuthorization()
            } else {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
                //defaults.set(true, forKey: "FirstLaunch")
                
            }
        }else{
            print("First")
            performSegue(withIdentifier: "toTermsView", sender: nil)
            //defaults.set(true, forKey: "FirstLaunch")
            locationManager.requestAlwaysAuthorization()
            if CLLocationManager.authorizationStatus() != .authorizedAlways
            {
                locationManager.requestAlwaysAuthorization()
            }
            if CLLocationManager.authorizationStatus() == .authorizedAlways{
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        
            let timerightnow = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-d-YYYY HH:mm"
            
            let installed = formatter.string(from: timerightnow)
            
            // get the date time String from the date object
            //print("Installed:", installed)
            let scheduledupdate = Calendar.current.date(byAdding: .minute,value:1, to: formatter.date(from: installed) ?? Date())
            //print("Next update:", scheduledupdate as Any)
            defaults.set(scheduledupdate, forKey: "NextUpdate")
            defaults.set("", forKey: "LocationArray")
            defaults.set("", forKey: "timeofLocation")
        }
        let currentDate = Date()
        if defaults.bool(forKey: "COVIDPositive") == true {
            let dateofinfection = defaults.object(forKey:"dateofInfection") as! Date
            let day14 = Calendar.current.date(byAdding: .day, value: 1, to: dateofinfection)!
            if currentDate < day14 {
                self.instructions.text = "Thank you for notifying us. This button will be disabled for the next 14 days."
               self.infectedButton.isEnabled = false
            }
        }else{
               self.infectedButton.isEnabled = true
               self.infected = 0
             self.instructions.text = "Notify us if you have tested positive for Covid-19."
               self.defaults.set(false, forKey: "COVIDPositive")
           }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let locationstring = String(locValue.latitude)+","+String(locValue.longitude)
        var locationArr = defaults.object(forKey: "LocationArray") as! String
        if locationArr == "" {
            locationArr.append(locationstring)
        }else{
            locationArr.append(",")
            locationArr.append(locationstring)
            
        }
        //print(locationArr)
        defaults.set(locationArr, forKey: "LocationArray")
        
        let timerightnow = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-d-YYYY HH:mm"
        var dateArr = defaults.object(forKey: "timeofLocation") as! String
        if dateArr == "" {
            dateArr.append(formatter.string(from: timerightnow))
        }else{
            dateArr.append(",")
            dateArr.append(formatter.string(from: timerightnow))
        }
        defaults.set(dateArr, forKey: "timeofLocation")
        let scheduledupdate = defaults.object(forKey: "NextUpdate") as! Date
        //print("Date", scheduledupdate as Any)
        if timerightnow >= scheduledupdate{
            makePostCall()
            let nextupdate = Calendar.current.date(byAdding: .hour,value:1, to: timerightnow)
            //print("Next Update:", nextupdate as Any)
            defaults.set(nextupdate, forKey: "NextUpdate")
            defaults.set("", forKey: "LocationArray")
            defaults.set("", forKey: "timeofLocation")
        }else{
            //do nothing
            //print("Not yet")
        }
            
        
    }
    
    @IBAction func updateDiagnosis(_ sender: Any) {
        let dialogMessage = UIAlertController(title: "Confirm", message: "Would you like to update your diagnosis to positive?", preferredStyle: .alert)
        // Create OK button with action handler
               let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                self.makePostCall()
                self.defaults.set("", forKey: "LocationArray")
                self.infected = 1
                self.makePutCall()
                self.infectedButton.isEnabled = false
                self.instructions.text = "Thank you. This button will be disabled for the next 14 days."
                self.defaults.set(true, forKey: "COVIDPositive")
                self.defaults.set(Date(), forKey: "dateofInfection")
                    
               })
               // Create Cancel button with action handlder
               let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                self.infected = 0
                
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
         // print("The todo is: " + todo.description)

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
        let locationArr = defaults.object(forKey: "LocationArray") as! String
        let dateArr = defaults.object(forKey: "timeofLocation") as! String
        defaults.set("", forKey: "LocationArray")
        defaults.set("", forKey: "timeofLocation")
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else { return }
        print("dateArr:", dateArr)
      let todosEndpoint: String = "http://www.aisarhan.com/CoronaAPI/api/GeoTrackerController/StoreUseLoction"
      guard let todosURL = URL(string: todosEndpoint) else {
        print("Error: cannot create URL")
        return
      }
      var todosUrlRequest = URLRequest(url: todosURL)
      todosUrlRequest.httpMethod = "POST"
        todosUrlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-type")
        let newTodo: [String: String] = ["deviceid":uuid, "location": locationArr, "locationdate": dateArr]
      let jsonTodo: Data
      do {
        jsonTodo = try JSONSerialization.data(withJSONObject: newTodo, options: [])
        todosUrlRequest.httpBody = jsonTodo
        print("req:", String(decoding:jsonTodo, as:UTF8.self))
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
        print("responseDataLoc",String(decoding:responseData, as:UTF8.self))

      }
      task.resume()
    }
    //PUT Call
    func makePutCall() {
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else { return }
      let todosEndpoint: String = "http://www.aisarhan.com/CoronaAPI/api/NotificationController/NotifyCorona"
      guard let todosURL = URL(string: todosEndpoint) else {
        print("Error: cannot create URL")
        return
      }
      var todosUrlRequest = URLRequest(url: todosURL)
      todosUrlRequest.httpMethod = "PUT"
        todosUrlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-type")
      let newTodo: [String: Any] = ["deviceid":uuid, "hasCorona": 1]
      let jsonTodo: Data
      do {
        jsonTodo = try JSONSerialization.data(withJSONObject: newTodo, options: [])
        todosUrlRequest.httpBody = jsonTodo
        //print("JsonTodo")
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
    
    func writeToFile(content: String, fileName: String) {

        let contentToAppend = content+"\n"
        let filePath = getDocumentsDirectory().appendingPathComponent("output.txt")
            //Create new file
            do {
                //append to file
                try contentToAppend.write(toFile: filePath.absoluteString, atomically: false, encoding: String.Encoding.utf8)
            } catch {
                print("Error creating \(filePath)")
            }
    }
    
    
}


