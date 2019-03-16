//
//  tab3ViewController.swift
//  kush
//
//  Created by Daniel on 3/15/19.
//  Copyright © 2019 admin2. All rights reserved.
//

import UIKit
import Auk
import Firebase

class tab3ViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var imageset = [UIImage]()
    var recset = [String]()
    var curAlign = 0
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBAction func buttonPressed(_ sender: Any) {
        switch(self.curAlign % 3) {
        case 0:
            self.textLabel.textAlignment = .left
            self.curAlign += 1
        case 1:
            self.textLabel.textAlignment = .right
            self.curAlign += 1
        case 2:
            self.textLabel.textAlignment = .center
            self.curAlign += 1
        default:
            self.textLabel.textAlignment = .left
            self.curAlign = 0
        }
        
        var newtext = self.recset.randomElement()
        while (self.textLabel.text == newtext) {
            newtext = self.recset.randomElement()
        }
        
        self.textLabel.text = newtext
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.auk.settings.contentMode = .scaleAspectFill
        
        //Set images to display
        if self.imageset.count < 1 {
            for num in 1...9 {
                let imgname = "backgrounds/" + String(num) + ".jpg"
                self.imageset.append(UIImage(named: imgname)!)
            }
        }
        
        if self.recset.count < 1 {
            getRecommendations()
        }

        self.view.sendSubviewToBack(scrollView)
    }
    
    func getRecommendations() {
        let ref = appDelegate.ref!
        
        ref.child("recommendations").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                
                self.recset.append(rest.value as! String)
            }
            self.textLabel.text = self.recset.randomElement()
            self.showImages()
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func showImages() {
        scrollView.auk.startAutoScroll(delaySeconds: 3)
        
        for localImage in self.imageset {
            scrollView.auk.show(image: localImage)
        }
    }
}
