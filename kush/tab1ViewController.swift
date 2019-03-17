//
//  tab1ViewController.swift
//  kush
//
//  Created by Daniel on 3/15/19.
//  Copyright © 2019 admin2. All rights reserved.
//

import UIKit
import Charts
import Firebase
import FirebaseDatabase
import SwiftyJSON

class tab1ViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentSnapshot: Dictionary<String, Any> = [:]
    var chartEntries: Dictionary<String, Int> = [:]
    
    @IBOutlet weak var chartArea: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    
    func getData() {
        let ref = appDelegate.ref!
        //CHANGE THIS TO CHANGE USER
        let uid = "sample_user" //appDelegate.uid!
        
        ref.child("location_data").child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            self.currentSnapshot = snapshot.value as? NSDictionary as! Dictionary<String, Any>
        
            self.setEntries(snapshot: snapshot)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func convertDatetime(timestamp: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(UInt64(timestamp)!))
        let formatter = DateFormatter()
        
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    // Sets the entries for the chart data.
    func setEntries(snapshot: DataSnapshot) {
    
        // Count number of unique locations
        for rest in snapshot.children.allObjects as! [DataSnapshot] {
            
            var locdata = rest.value as! Dictionary<String, Any>
            var locset = [String]()
            
            for locationdata in locdata{
                
                var jsondata = JSON(locationdata.value)
                var uniqueLocation = jsondata["names"].description

                if !locset.contains(uniqueLocation) {
                    locset.append(uniqueLocation)
                }
            }
            
            self.chartEntries[rest.key] = locset.count
        }
        self.updateChart()
    }
    
    func updateChart() {

        var dataEntries: [BarChartDataEntry] = []
        var xvals = [String]()
        var i = 0
        
        for (key, val) in self.chartEntries.sorted(by: <	) {
            let dataEntry = BarChartDataEntry(x:Double(i), y:Double(val))
            dataEntries.append(dataEntry)
            xvals.append(key)
            i = i + 1
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Number of Locations")
        let chartData = BarChartData(dataSet: chartDataSet)

        self.chartArea.xAxis.valueFormatter = IndexAxisValueFormatter(values:xvals)
        self.chartArea.xAxis.granularity = 1
        self.chartArea.rightAxis.enabled = false
        self.chartArea.leftAxis.granularityEnabled = true
        self.chartArea.leftAxis.granularity = 1
        
        self.chartArea.drawGridBackgroundEnabled = false
        self.chartArea.xAxis.labelPosition = .bottom
        self.chartArea.data=chartData
    }
    
}
