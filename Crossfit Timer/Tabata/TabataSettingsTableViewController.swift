//
//  TabataSettingsTableViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 01.06.18.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit

protocol TabataSettingsDelegate {
    func changeWorkTime(sec : Int)
    func changeRelaxTimer(sec : Int)
    func changeRounds(rounds : Int)
    func changeDelay(sec : Int)
}

class TabataSettingsTableViewController: SettingsTableViewController {

    @IBOutlet weak var workTimeLabel: UILabel!
    @IBOutlet weak var workTimePicker: UIPickerView!
    @IBOutlet weak var relaxTimeLabel: UILabel!
    @IBOutlet weak var relaxTimePicker: UIPickerView!
    @IBOutlet weak var roundsLabel: UILabel!
    @IBOutlet weak var roundsPicker: UIPickerView!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var delayPicker: UIPickerView!
    
    var delegate: TabataSettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workTimePicker.delegate = self
        workTimePicker.dataSource = self
        workTimePicker.isHidden = true
        relaxTimePicker.delegate = self
        relaxTimePicker.dataSource = self
        relaxTimePicker.isHidden = true
        roundsPicker.delegate = self
        roundsPicker.dataSource = self
        roundsPicker.isHidden = true
        delayPicker.delegate = self
        delayPicker.dataSource = self
        delayPicker.isHidden = true
        setLabelsAndPickers()
        tableView.tableFooterView = UIView()
        delegate = navigationController?.viewControllers[0] as? TabataSettingsDelegate
    }
    
    func setLabelsAndPickers() {
        var seconds = UserDefaults.standard.integer(forKey: "TabataWork")
        var min = Int(seconds / 60)
        var sec = Int(seconds) % 60
        var str = ""
        str += min < 10 ? "0\(min):" : "\(min):"
        str += sec < 10 ? "0\(sec)"  : "\(sec)"
        workTimePicker.selectRow(min, inComponent: 0, animated: false)
        workTimePicker.selectRow(sec, inComponent: 1, animated: false)
        workTimeLabel.text = str
        
        seconds = UserDefaults.standard.integer(forKey: "TabataRelax")
        min = Int(seconds / 60)
        sec = Int(seconds) % 60
        str = ""
        str += min < 10 ? "0\(min):" : "\(min):"
        str += sec < 10 ? "0\(sec)"  : "\(sec)"
        relaxTimePicker.selectRow(min, inComponent: 0, animated: false)
        relaxTimePicker.selectRow(sec, inComponent: 1, animated: false)
        relaxTimeLabel.text = str
        
        let rounds = UserDefaults.standard.integer(forKey: "TabataRounds")
        roundsPicker.selectRow(rounds, inComponent: 0, animated: false)
        roundsLabel.text = "\(rounds)"
        
        let delay = UserDefaults.standard.integer(forKey: "TabataDelay")
        delayPicker.selectRow(delay, inComponent: 0, animated: false)
        delayLabel.text = "\(delay) сек"
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            let height: CGFloat = workTimePicker.isHidden ? 0.0 : 216.0
            return height
        } else if indexPath.row == 3 {
            let height: CGFloat = relaxTimePicker.isHidden ? 0.0 : 216.0
            return height
        } else if indexPath.row == 5 {
            let height: CGFloat = roundsPicker.isHidden ? 0.0 : 216.0
            return height
        } else if indexPath.row == 7 {
            let height: CGFloat = delayPicker.isHidden ? 0.0 : 216.0
            return height
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            workTimePicker.isHidden = !workTimePicker.isHidden
            animatePicker(in: indexPath)
        } else if indexPath.row == 2 {
            relaxTimePicker.isHidden = !relaxTimePicker.isHidden
            animatePicker(in: indexPath)
        } else if indexPath.row == 4 {
            roundsPicker.isHidden = !roundsPicker.isHidden
            animatePicker(in: indexPath)
        } else if indexPath.row == 6 {
            delayPicker.isHidden = !delayPicker.isHidden
            animatePicker(in: indexPath)
        }
    }
}

extension TabataSettingsTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 || pickerView.tag == 1 {
            return 2
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 || pickerView.tag == 1 {
            if component == 0 {
                return "\(row) мин"
            }
            return "\(row) сек"
        } else if pickerView.tag == 2 {
            return "\(row)"
        }
        return "\(row) сек"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 || pickerView.tag == 1 {
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
            
            if pickerView.tag == 0 {
                UserDefaults.standard.set(min * 60 + sec, forKey: "TabataWork")
                delegate?.changeWorkTime(sec: min * 60 + sec)
                workTimeLabel.text = str
            } else {
                UserDefaults.standard.set(min * 60 + sec, forKey: "TabataRelax")
                delegate?.changeRelaxTimer(sec: min * 60 + sec)
                relaxTimeLabel.text = str
            }
        } else if pickerView.tag == 2 {
            let rounds = pickerView.selectedRow(inComponent: 0)
            roundsLabel.text = "\(rounds)"
            UserDefaults.standard.set(rounds, forKey: "TabataRounds")
            delegate?.changeRounds(rounds: rounds)
        } else if pickerView.tag == 3 {
            let sec = pickerView.selectedRow(inComponent: 0)
            delayLabel.text = "\(sec) сек"
            UserDefaults.standard.set(sec, forKey: "TabataDelay")
            delegate?.changeDelay(sec: sec)
        }
    }
}
