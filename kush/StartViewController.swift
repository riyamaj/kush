//
//  StartViewController.swift
//  kush
//
//  Created by Daniel on 3/15/19.
//  Copyright © 2019 admin2. All rights reserved.
//

import UIKit
import Charts

class StartViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dbaccessor: DBAccessor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dbaccessor = DBAccessor()
        appDelegate.dbaccessor = self.dbaccessor

    }
    
    @IBAction func ButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToTabBar", sender: self)
    }
}
