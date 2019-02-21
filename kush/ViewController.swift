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

class ViewController: UIViewController, CLLocationManagerDelegate {

    var ref: DatabaseReference!
    let healthStore = HKHealthStore()
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
        let uid = UIDevice.current.identifierForVendor!.uuidString
        ref.child("users").child(uid).setValue(["username": "abhi"])
        determineMyCurrentLocation()
        
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

    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
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

