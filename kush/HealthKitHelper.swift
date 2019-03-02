//
//  HealthKitHelper.swift
//  kush
//
//  Created by admin2 on 3/1/19.
//  Copyright © 2019 admin2. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitHelper {
    let storage = HKHealthStore()
    
    init()
    {
        checkAuthorization()
    }
    
    func checkAuthorization() -> Bool
    {
        // Default to assuming that we're authorized
        var isEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable()
        {
            // We have to request each data type explicitly
            let to_read = NSSet(objects: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!, HKQuantityType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!)
            // Now we can request authorization for step count data
            storage.requestAuthorization(toShare: nil, read: to_read as? Set<HKObjectType>) { (success, error) -> Void in
                isEnabled = success
            }
    
        }
        else
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    func sleepAmount(completion: @escaping (Double, NSError?) -> () )
    {
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            let predicate = HKQuery.predicateForSamples(withStart: NSDate(timeIntervalSinceNow: TimeInterval(-86400)) as Date, end: NSDate() as Date, options: [])
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                var totalSleepTime = 0.0
                if let result = tmpResult {
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            //time in bed is assumed to be sleeping time...
//                            if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                                let timeInterval = sample.endDate.timeIntervalSince(sample.startDate)
                                totalSleepTime += timeInterval.binade
//                            }
                        }
                    }
                }
                completion(totalSleepTime, error as NSError?)
            }
            
            storage.execute(query)
        }
    }
    
    func recentSteps(completion: @escaping (Double, NSError?) -> () )
    {
        // The type of data we are requesting (this is redundant and could probably be an enumeration
        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        // Our search predicate which will fetch data from now until a day ago
        // (Note, 1.day comes from an extension
        // You'll want to change that to your own NSDate
        let predicate = HKQuery.predicateForSamples(withStart: NSDate(timeIntervalSinceNow: TimeInterval(-86400)) as Date, end: NSDate() as Date, options: [])
        
        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Double = 0
            
            if results?.count ?? 0 > 0
            {
                for result in results as! [HKQuantitySample]
                {
                    steps += result.quantity.doubleValue(for: HKUnit.count())
                }
            }
            
            completion(steps, error as NSError?)
        }
        
        storage.execute(query)
    }
}
