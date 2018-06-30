//
//  StopwatchViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 08.04.18.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit
import MediaPlayer

class StopwatchViewController: TimerVC, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var miliSecondsLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var resetLapButton: UIButton!
    @IBOutlet override weak var countdownLabel: UILabel! {
        didSet { }
    }
    
    var lapTimeArray = [String]()
    var totalSec: Double = 0.0
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.tableHeaderView = UIView()
    }
    
    //MARK: Background/Foreground
    @objc override func pauseWhenBackground(noti: Notification) {
        timer.invalidate()
        UserDefaults.standard.set(Date(), forKey: "StopWatchSavedDate")
        print("\(Date()) ApplicationDidEnterBackground")
    }
    
    @objc override func willEnterForeground(noti: Notification) {
        if isTimerWorking {
            if let savedDate = UserDefaults.standard.object(forKey: "StopWatchSavedDate") as? Date{
                let difSec = savedDate.timeIntervalSinceNow * -1
                print("\(Date()) ApplicationWillEnterForeground")
                print("dif is \(difSec)")
                totalSec += difSec
                startTimer()
            }
        }
    }
    
    //MARK: - TIMER
    override func startCountdown() {
        delay = UserDefaults.standard.integer(forKey: "StopWatchDelay")
        super.startCountdown()
    }
    
    override func countdown() {
        delay = UserDefaults.standard.integer(forKey: "StopWatchDelay")
        super.countdown()
    }
    
    override func startTimer () {
        super.startTimer()
        startStopButton.setTitle("Стоп", for: UIControlState.normal)
        resetLapButton.setTitle("Круг", for: UIControlState.normal)
    }
    
    @objc override func updateTimer() {
        super.updateTimer()
        totalSec += 0.01
        
        let formatedTime = getFormatedTime(from: totalSec)
        
        minuteLabel.text = formatedTime.min
        secondsLabel.text = formatedTime.sec
        miliSecondsLabel.text = formatedTime.miliSec
        let timeToRing = UserDefaults.standard.integer(forKey: "StopWatchTimeToRing")
        progressView.progress = Float((totalSec - Double(timeToRing * signals)) / Double(timeToRing))
        
        if progressView.progress == 1 {
            signals += 1
            longBeepPlayer.play()
        }
    }
    
    override func resetAll() {
        super.resetAll()
        totalSec = 0
        minuteLabel.text = "00"
        secondsLabel.text = "00"
        miliSecondsLabel.text = "00"
        progressView.progress = 0
        lapTimeArray.removeAll()
        tableView.reloadData()
        startStopButton.setTitle("Старт", for: UIControlState.normal)
        resetLapButton.setTitle("Сброс", for: UIControlState.normal)
        resetLapButton.isEnabled = false
        navigationController?.navigationBar.isUserInteractionEnabled = true
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    //MARK: - Actions
    @IBAction func startStopButtonPressed(_ sender: UIButton) {
        resetLapButton.isEnabled = true
        if isDelayTimerWorking {
            resetAll()
        } else {
            if isTimerWorking {
                timer.invalidate()
                isTimerWorking = false
                startStopButton.setTitle("Дальше", for: UIControlState.normal)
                resetLapButton.setTitle("Сброс", for: UIControlState.normal)
            } else {
                if totalSec != 0.0 {
                    startTimer()
                } else {
                    startCountdown()
                }
            }
            navigationController?.navigationBar.isUserInteractionEnabled = false
            navigationController?.navigationBar.tintColor = UIColor.lightGray
        }
    }
    
    @IBAction func resetLapButtonPressed(_ sender: UIButton) {
        if isDelayTimerWorking {
            resetAll()
        } else {
            if isTimerWorking {
                lapTimeArray.append("\(minuteLabel.text!):\(secondsLabel.text!),\(miliSecondsLabel.text!)")
                tableView.reloadData()
            } else {
                resetAll()
            }
        }
    }
}

//MARK: - TableView
extension StopwatchViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapTimeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = "Круг \(indexPath.row + 1)"
        cell.detailTextLabel?.textColor = .white
        cell.detailTextLabel?.text = lapTimeArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1 / UIScreen.main.scale
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: (self.tableView.frame.size.width), height: px)
        let line = UIView(frame: frame)
        line.backgroundColor = self.tableView.separatorColor
        return line
    }
}
