//
//  TermsController.swift
//  Locator
//
//  Created by Simran Bhattarai on 2020-04-20.
//  Copyright © 2020 Simran Bhattarai. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class TermsController: UIViewController {
    //let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        //locationManager.requestAlwaysAuthorization()
        UserDefaults.standard.set(true, forKey: "termsAccepted")
        self.dismiss(animated: true, completion: nil)
    }
    
}

