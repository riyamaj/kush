//
//  ViewController.swift
//  kush
//
//  Created by admin2 on 2/21/19.
//  Copyright © 2019 admin2. All rights reserved.
//

import UIKit
import Firebase
import HealthKit
import CoreLocation
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    var uid: String!
    
    let healthStore = HKHealthStore()
    var locationManager:CLLocationManager!
    private var startTime: Date? //An instance variable, will be used as a previous location time.

    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set DB ref and uid to appDelegate
        self.ref = appDelegate.ref
        self.uid = appDelegate.uid
        
        setupUser()
        
        //Setup location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        //ref.child("users").child(uid!).setValue(["username": "daniel"])
        
//      var timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {
//          timer in
//
//          self.someBackgroundTask(timer: timer)
//      }
        
//        let typestoRead = Set([
//            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
//            ])
//
//        let typestoShare = Set([
//            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
//            ])
//
//        self.healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) -> Void in
//            if success == false {
//                NSLog(" Display not allowed")
//            } else {
////                self.retrieveSleepAnalysis()
//            }
//        }
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        var userText = textField.text!
        ref.child("users").child(uid!).updateChildValues(["extra": userText])
        statusLabel.text = userText

        //determineMyCurrentLocation()
        startTimer()
    }
    
    
    func startTimer() {
        // Timer fires every 5 seconds, then sleeps for 10
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (t) in
            print("Timer PRINT")
            self.locationManager.requestLocation()
            sleep(10)
        }
    }
    
    
    // Sets up user the first time they start up the app
    func setupUser() {
        //ref.child("users").child(uid).setValue(["username": "daniel"])
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                print("User already exists")
            }
            else{
                //Setup user in users table
                self.ref.child("users").child(self.uid).setValue(["username": self.uid])
                
                //Setup user in location table
                self.ref.child("location_data").child("users").child(self.uid).setValue("")
                
                //Setup user in sleep_data
                
            }
        })
    }
    
    // Returns todays date in yyyy-mm-dd
    func getTodaysDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // Returns the current epoch in seconds
    func getCurrentEpoch() -> UInt64 {
        return UInt64(NSDate().timeIntervalSince1970)
    }
    
    // Returns readable date from epoch in seconds
    func convertEpoch(timestamp: UInt64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    // Pushes the current location to firebase
    func pushLocation(location: CLLocation) {
        let date = getTodaysDate()
        let timestamp = String(getCurrentEpoch())
        let placetype = "unknown"
        
        let locData = ["latitude": location.coordinate.latitude,
                        "longitude": location.coordinate.longitude,
                        "type": placetype] as [String : Any]
        
        let updateObject = [timestamp: locData]
        // Push to Database
        ref.child("location_data/users").child(uid).child(date).updateChildValues(updateObject)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation

        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("Upload updated location to server")
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        pushLocation(location: userLocation)

        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

    func retrieveSleepAnalysis() {
        
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    // something happened
                    return
                    
                }
                
                if let result = tmpResult {
                    
                    // do something with my data
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                        }
                    }
                }
            }
            
            // finally, we execute our query
            healthStore.execute(query)
        }
    }

}

