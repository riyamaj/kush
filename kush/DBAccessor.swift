//
//  DBAccessor.swift
//  kush
//
//  Created by Daniel on 3/15/19.
//  Copyright © 2019 admin2. All rights reserved.
//

import Firebase
import CoreLocation
import Foundation
import Alamofire

class DBAccessor: NSObject, CLLocationManagerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var hkh: HealthKitHelper!
    var locationManager:CLLocationManager!
    var ref: DatabaseReference!
    var uid: String!
    
    override init() {
        super.init()
        
        //Set DB ref and uid to appDelegate
        self.ref = appDelegate.ref
        self.uid = appDelegate.uid
        self.hkh = HealthKitHelper()
        
        setupUser()
        setupLocationManager()
        
        startLocationTimer()
        startHealthTimer()
        
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
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
                self.ref.child("sleep_data").child("users").child(self.uid).setValue("")
                
                //Setup user in step_data
                self.ref.child("step_data").child("users").child(self.uid).setValue("")
            }
        })
    }
    
    
    func enrichLocationWithGoogle(location:CLLocation) {
        AF.request("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=25&key=AIzaSyAmFtGkGjnjUBknBXwJNtJmJlskLNU4jQE").responseJSON { response in
            if let json = response.result.value {
                let response = json as! NSDictionary
                var types_arr: [String] = []
                let results = response.object(forKey: "results")! as! [NSDictionary]
                var counter = 0
                var names_arr:[String] = []
                while counter < min(4, results.count) {
                    let result = results[counter]
                    let types = result.object(forKey: "types")! as! [String]
                    for type in types {
                        types_arr.append(type)
                    }
                    let name = result.object(forKey: "name")
                    if name != nil {
                        names_arr.append(name as! String)
                    }
                    counter += 1
                }
                let s = Array(Set(types_arr))
                var ret_string: String = ""
                
                s.forEach { value in
                    ret_string += value + ","
                }
                let t = Array(Set(names_arr))
                var ret_string2: String = ""
                
                t.forEach { value in
                    ret_string2 += value + ","
                }
                self.pushLocation(location: location, ret: ret_string, ret2: ret_string2)
            }
        }
    }
    
    // Pushes the current location to firebase
    func pushLocation(location: CLLocation, ret: String, ret2: String) {
        let date = getTodaysDate()
        let timestamp = String(getCurrentEpoch())
        let locData = ["latitude": location.coordinate.latitude,
                       "longitude": location.coordinate.longitude,
                       "types": ret,
                       "names": ret2,
                       "altitude": location.altitude.binade,
                       "speed": location.speed.binade] as [String : Any]
        
        let updateObject = [timestamp: locData]
        // Push to Database
        ref.child("location_data/users").child(uid).child(date).updateChildValues(updateObject)
        //textField.text = String(location.coordinate.latitude)
        print("Upload updated location to server")
    }
    
    // Pushes sleep amount to firebase
    func pushSleep(sleepAmount: Double) {
        let date = getTodaysDate()
        let timestamp = String(getCurrentEpoch())
        let sleepData = ["sleepAmount": sleepAmount] as [String : Any]
        
        let updateObject = [timestamp: sleepData]
        // Push to Database
        ref.child("sleep_data/users").child(uid).child(date).updateChildValues(updateObject)
        print("Upload sleep data to server")
    }
    
    // Pushes steps walked to firebase
    func pushSteps(stepAmount: Double) {
        let date = getTodaysDate()
        let timestamp = String(getCurrentEpoch())
        let stepData = ["steps": stepAmount] as [String : Any]
        
        let updateObject = [timestamp: stepData]
        // Push to Database
        ref.child("step_data/users").child(uid).child(date).updateChildValues(updateObject)
        print("Upload step data to server")
    }
    
    func startLocationTimer() {
        // Timer fires every 5 seconds, then sleeps for 10
        Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { (t) in
            self.locationManager.requestLocation()
            //sleep(10)
        }
    }
    
    func startHealthTimer() {
        // Timer fires every 60*60*24 seconds, then sleeps for 10
        Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { (t) in
            self.hkh.recentSteps() { steps, error in
                print("steps: " + String(steps))
                self.pushSteps(stepAmount: steps)
            }
            
            self.hkh.sleepAmount() { sleepAmount, error in
                print("sleep: " + String(sleepAmount))
                self.pushSleep(sleepAmount: sleepAmount)
            }
            //sleep(10)
        }
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        enrichLocationWithGoogle(location: userLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
}


