//
//  IntervalsSettingsTableViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 23.06.2018.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit

protocol IntervalsSettingsDelegate {
    
}

class IntervalsSettingsTableViewController: SettingsTableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var intervals: [Double] = []
    var isTimePickerHidden: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intervals = UserDefaults.standard.array(forKey: "IntervalsModeIntervals") as! [Double]
        isTimePickerHidden = Array(repeating: false, count: intervals.count)
    }
    
    //MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (intervals.count * 2) + 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let pickerCell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath) as! PickerCell
        let row = indexPath.row
        
        if row % 2 == 1 {
            pickerCell.timePicker.dataSource = self
            pickerCell.timePicker.delegate = self
            pickerCell.timePicker.isHidden = true
            if row == intervals.count * 2 + 1 {
                pickerCell.timePicker.tag = 2
            } else if row == intervals.count * 2 + 3 {
                pickerCell.timePicker.tag = 1
            }
            return pickerCell
        } else {
            if row < intervals.count * 2 {
                cell?.textLabel?.text = "Интервал \(row/2 + 1)"
            } else if row == intervals.count * 2 {
                cell?.textLabel?.text = "Задержка"
            } else {
                cell?.textLabel?.text = "Раунды"
            }
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 1 {
            let pickerCell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath) as! PickerCell
                let height: CGFloat = pickerCell.timePicker.isHidden ? 0.0 : 216.0
                return height
            
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            let pickerCell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath) as? PickerCell
            pickerCell?.timePicker.isHidden = !(pickerCell?.timePicker.isHidden)!
            animatePicker(in: indexPath)
        }
    }
    
    //MARK: - PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag != 0 {
            return 1
        }
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            if component == 0 {
                return "\(row) мин"
            }
            return "\(row) сек"
        } else if pickerView.tag == 1 {
            return "\(row)"
        }
        return "\(row) сек"
    }
    
}























