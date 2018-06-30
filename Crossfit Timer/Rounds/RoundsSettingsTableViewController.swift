//
//  RoundsSettingsTableViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 23.06.2018.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit

protocol RoundsSettingsDelegate {
    func changeTime(sec : Int)
    func changeRounds(rounds : Int)
    func changeDelay(sec : Int)
}

class RoundsSettingsTableViewController: SettingsTableViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var roundsLabel: UILabel!
    @IBOutlet weak var roundsPicker: UIPickerView!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var delayPicker: UIPickerView!
    
    var delegate: RoundsSettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.isHidden = true
        roundsPicker.delegate = self
        roundsPicker.dataSource = self
        roundsPicker.isHidden = true
        delayPicker.delegate = self
        delayPicker.dataSource = self
        delayPicker.isHidden = true
        setLabelsAndPickers()
        tableView.tableFooterView = UIView()
        delegate = navigationController?.viewControllers[0] as? RoundsViewController
    }
    
    func setLabelsAndPickers() {
        let seconds = UserDefaults.standard.integer(forKey: "RoundsModeTime")
        let min = Int(seconds / 60)
        let sec = Int(seconds) % 60
        var str = ""
        str += min < 10 ? "0\(min):" : "\(min):"
        str += sec < 10 ? "0\(sec)"  : "\(sec)"
        timePicker.selectRow(min, inComponent: 0, animated: false)
        timePicker.selectRow(sec, inComponent: 1, animated: false)
        timeLabel.text = str
        
        let rounds = UserDefaults.standard.integer(forKey: "RoundsModeRounds")
        roundsPicker.selectRow(rounds, inComponent: 0, animated: false)
        roundsLabel.text = "\(rounds)"
        
        let delay = UserDefaults.standard.integer(forKey: "RoundsModeDelay")
        delayPicker.selectRow(delay, inComponent: 0, animated: false)
        delayLabel.text = "\(delay) сек"
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            let height: CGFloat = timePicker.isHidden ? 0.0 : 216.0
            return height
        } else if indexPath.row == 3 {
            let height: CGFloat = roundsPicker.isHidden ? 0.0 : 216.0
            return height
        } else if indexPath.row == 5 {
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
            roundsPicker.isHidden = !roundsPicker.isHidden
            animatePicker(in: indexPath)
        } else if indexPath.row == 4 {
            delayPicker.isHidden = !delayPicker.isHidden
            animatePicker(in: indexPath)
        }
    }
    
}

extension RoundsSettingsTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        } else if pickerView.tag == 1 {
            return "\(row)"
        }
        return "\(row) сек"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            var str = ""
            let min = pickerView.selectedRow(inComponent: 0)
            var sec = pickerView.selectedRow(inComponent: 1)
            
            if min == 0 && sec < 3 {
                pickerView.selectRow(0, inComponent: 0, animated: true)
                pickerView.selectRow(3, inComponent: 1, animated: true)
                str = "00:03"
                sec = 3
            } else {
                str += min < 10 ? "0\(min):" : "\(min):"
                str += sec < 10 ? "0\(sec)"  : "\(sec)"
            }
            
            UserDefaults.standard.set(min * 60 + sec, forKey: "RoundsModeTime")
            delegate?.changeTime(sec: min * 60 + sec)
            timeLabel.text = str
        } else if pickerView.tag == 1 {
            let rounds = pickerView.selectedRow(inComponent: 0)
            roundsLabel.text = "\(rounds)"
            UserDefaults.standard.set(rounds, forKey: "RoundsModeRounds")
            delegate?.changeRounds(rounds: rounds)
        } else if pickerView.tag == 2 {
            let sec = pickerView.selectedRow(inComponent: 0)
            delayLabel.text = "\(sec) сек"
            UserDefaults.standard.set(sec, forKey: "RoundsModeDelay")
            delegate?.changeDelay(sec: sec)
        }
    }
}
