//
//  StopWatchSettingsTableViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 21.04.18.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit

class StopWatchSettingsTableViewController: UITableViewController {

    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var delayPicker: UIPickerView!
    @IBOutlet weak var delayLabel: UILabel!
    
    var seconds: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.isHidden = true
        delayPicker.delegate = self
        delayPicker.dataSource = self
        delayPicker.isHidden = true
        tableView.tableFooterView = UIView()
        setLabelsAndPickers()
    }

    func setLabelsAndPickers() {
        let seconds = UserDefaults.standard.integer(forKey: "StopWatchTimeToRing")
        let delay = UserDefaults.standard.integer(forKey: "StopWatchDelay")
        let min = Int(seconds / 60)
        let sec = Int(seconds) % 60
        var str = ""
        str += min < 10 ? "0\(min):" : "\(min):"
        str += sec < 10 ? "0\(sec)"  : "\(sec)"
        
        timePicker.selectRow(min, inComponent: 0, animated: false)
        timePicker.selectRow(sec, inComponent: 1, animated: false)
        delayPicker.selectRow(delay, inComponent: 0, animated: false)
        
        timeLabel.text = str
        delayLabel.text = "\(delay) сек"
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            let height: CGFloat = timePicker.isHidden ? 0.0 : 216.0
            return height
        } else if indexPath.row == 3 {
            let height: CGFloat = delayPicker.isHidden ? 0.0 : 216.0
            return height
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            timePicker.isHidden = !timePicker.isHidden
            animatePicker(in: indexPath)
        } else if indexPath.row == 2 {
            delayPicker.isHidden = !delayPicker.isHidden
            animatePicker(in: indexPath)
        }
    }
    
    func animatePicker(in indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.tableView.beginUpdates()
            // apple bug fix - some TV lines hide after animation
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.endUpdates()
        })
    }
    
}

extension StopWatchSettingsTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 {
            return 2
        }
        return 1
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
        }
        return "\(row) сек"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            var str = ""
            let min = pickerView.selectedRow(inComponent: 0)
            let sec = pickerView.selectedRow(inComponent: 1)
            
            if min == 0 && sec < 3 {
                timePicker.selectRow(0, inComponent: 0, animated: true)
                timePicker.selectRow(3, inComponent: 1, animated: true)
                str = "00:03"
                UserDefaults.standard.set(3, forKey: "StopWatchTimeToRing")
            } else {
                str += min < 10 ? "0\(min):" : "\(min):"
                str += sec < 10 ? "0\(sec)"  : "\(sec)"
                UserDefaults.standard.set(min * 60 + sec, forKey: "StopWatchTimeToRing")
            }
            timeLabel.text = str
        } else {
            let sec = pickerView.selectedRow(inComponent: 0)
            delayLabel.text = "\(sec) сек"
            UserDefaults.standard.set(sec, forKey: "StopWatchDelay")
        }
    }
}
