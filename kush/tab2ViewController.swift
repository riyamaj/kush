//
//  tab2ViewController.swift
//  kush
//
//  Created by Daniel on 3/15/19.
//  Copyright © 2019 admin2. All rights reserved.
//

import UIKit
import Charts
import Firebase
import SwiftyJSON

class tab2ViewController: UIViewController {
    
    var entries = [PieChartDataEntry]()
    var chartEntries: Dictionary<String, Int> = [:]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentSnapshot: Dictionary<String, Any> = [:]
    
    @IBOutlet weak var chartArea: PieChartView!
    @IBOutlet weak var labelDaily: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setData()
        getData()
    }
    
    // Returns readable date from epoch in seconds
    func convertEpoch(timestamp: UInt64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    func getData() {
        let ref = appDelegate.ref!
        //CHANGE THIS TO CHANGE USER
        let uid = "sample_user" //appDelegate.uid!
        
        ref.child("step_data").child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            self.currentSnapshot = snapshot.value as? NSDictionary as! Dictionary<String, Any>
            
            self.setEntries(snapshot: snapshot)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    // Sets the entries for the chart data.
    func setEntries(snapshot: DataSnapshot) {
        
        var legendEntries = [LegendEntry]()
        var selectedColors = [NSUIColor]()
        
        let colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        
        // Count number of unique locations
        for rest in snapshot.children.allObjects as! [DataSnapshot] {
            
            var stepdata = rest.value as! Dictionary<String, Any>
            
            self.labelDaily.text = "Daily Steps: " + rest.key
            
            var num = 0
            var totalsteps = 0
            
            for (key, value) in stepdata {

                var timestamp = self.convertEpoch(timestamp: UInt64(key)!)
                var data = value as! Dictionary<String, Int>
                var steps = data["steps"]!
                
                
                var entry = PieChartDataEntry(value: Double(steps))
                var legentry = LegendEntry()
                legentry.label = timestamp
                legentry.formColor = colors[num]
                legendEntries.append(legentry)
                
                selectedColors.append(colors[num])
                
                self.entries.append(entry)
                
                num += 1
                totalsteps = totalsteps + steps
            }
            

            self.updateChart(legendEntries: legendEntries, selectedColors: selectedColors)
            self.labelTotal.text = "Total Steps: " + String(totalsteps)
        }
        //self.updateChart()
    }
    
    
    func updateChart(legendEntries: [LegendEntry], selectedColors: [NSUIColor]) {
        
        let set = PieChartDataSet(values: self.entries, label: "Steps at Time")
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        set.colors = selectedColors
        
        /*
        set.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        */
        
        let data = PieChartData(dataSet: set)
        
        /*
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .ordinal
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        */

        
        let legend = chartArea.legend

        legend.setCustom(entries: legendEntries)
        legend.enabled = true
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.black)
        
        chartArea.data = data
        chartArea.highlightValues(nil)
    }
}
