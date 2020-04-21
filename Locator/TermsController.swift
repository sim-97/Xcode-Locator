//
//  TermsController.swift
//  Locator
//
//  Created by Simran Bhattarai on 2020-04-20.
//  Copyright © 2020 Simran Bhattarai. All rights reserved.
//

import Foundation
import UIKit


class TermsController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "termsAccepted")
        self.dismiss(animated: true, completion: nil)
    }
    
}

