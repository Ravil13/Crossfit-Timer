//
//  SettingsTableViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 29.06.2018.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    func animatePicker(in indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.tableView.beginUpdates()
            // apple bug fix - some TV lines hide after animation
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.endUpdates()
        })
    }
    
    func getFormatedTime(from time: Double) -> (min: String, sec: String, miliSec: String) {
        let min = Int(time / 60)
        let sec = Int(time) % 60
        let miliSec = Int(time * 100) % 100
        
        let minStr = min < 10 ? "0\(min)" : "\(min)"
        let secStr = sec < 10 ? "0\(sec)" : "\(sec)"
        let miliSecStr = (miliSec / 10 == 0) ? "\(miliSec)0" : "\(miliSec)"
        return (minStr, secStr, miliSecStr)
    }
}
