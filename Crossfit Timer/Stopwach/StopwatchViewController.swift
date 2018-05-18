//
//  StopwatchViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 08.04.18.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit
import MediaPlayer

class StopwatchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var miliSecondsLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var resetLapButton: UIButton!
    @IBOutlet weak var countdownLabel: UILabel! {
        didSet {
            countdownLabel.text = "\(delay)"
            countdownLabel.layer.cornerRadius = countdownLabel.frame.size.height / 2
            countdownLabel.layer.masksToBounds = true
        }
    }
    
    var longBeepPlayer: AVAudioPlayer!
    var shortBeepPlayer: AVAudioPlayer!
    var timer = Timer()
    var delayTimer = Timer()
    var isTimerStarted = false
    var isDelayTimerStarted = false
    var signals = 0
    var delay = UserDefaults.standard.integer(forKey: "StopWatchDelay")
    var totalSec: Float = 0
    
    var lapTimeArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.tableHeaderView = UIView()
        setAudioPlayers()
    }
    
    func setAudioPlayers() {
        let longBeepUrl = Bundle.main.url(forResource: "longBeep", withExtension: "mp3")
        let shortBeepUrl = Bundle.main.url(forResource: "shortBeep", withExtension: "mp3")
        do {
            longBeepPlayer = try AVAudioPlayer(contentsOf: longBeepUrl!)
            shortBeepPlayer = try AVAudioPlayer(contentsOf: shortBeepUrl!)
            longBeepPlayer.prepareToPlay()
            shortBeepPlayer.prepareToPlay()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func startCountdown() {
        countdownLabel.isHidden = false
        delay = UserDefaults.standard.integer(forKey: "StopWatchDelay")
        if delay == 0 {
            countdownLabel.isHidden = true
            longBeepPlayer.play()
            startTimer()
        } else {
            countdownLabel.text = "\(delay)"
            delayTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.toValue = NSNumber(value: 1.5)
            animation.duration = 1
            animation.repeatCount = Float(delay+1)
            countdownLabel.layer.add(animation, forKey: nil)
            shortBeepPlayer.play()
        }
    }
    
    @objc func countdown() {
        delay = UserDefaults.standard.integer(forKey: "StopWatchDelay")
        signals += 1
        if delay - signals < 0{
            delayTimer.invalidate()
            signals = 0
            countdownLabel.isHidden = true
            isDelayTimerStarted = false
        } else if delay - signals == 0 {
            longBeepPlayer.play()
            countdownLabel.text = "GO!"
            startTimer()
        } else {
            isDelayTimerStarted = true
            countdownLabel.text = "\(delay - signals)"
            shortBeepPlayer.play()
        }
    }
    
    func startTimer () {
        isTimerStarted = true
        startStopButton.setTitle("Стоп", for: UIControlState.normal)
        resetLapButton.setTitle("Круг", for: UIControlState.normal)
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    
    @IBAction func startStopButtonPressed(_ sender: UIButton) {
        if isDelayTimerStarted {
            resetAll()
        } else {
            if isTimerStarted {
                timer.invalidate()
                signals = 0
                isTimerStarted = false
                startStopButton.setTitle("Старт", for: UIControlState.normal)
                resetLapButton.setTitle("Сброс", for: UIControlState.normal)
            } else {
                startCountdown()
            }
        }
    }
    
    func resetAll() {
        minuteLabel.text = "00"
        secondsLabel.text = "00"
        miliSecondsLabel.text = "00"
        progressView.progress = 0
        totalSec = 0
        signals = 0
        lapTimeArray.removeAll()
        tableView.reloadData()
        timer.invalidate()
        delayTimer.invalidate()
        countdownLabel.isHidden = true
        isDelayTimerStarted = false
        isTimerStarted = false
        startStopButton.setTitle("Старт", for: UIControlState.normal)
        resetLapButton.setTitle("Сброс", for: UIControlState.normal)
    }
    
    @IBAction func resetLapButtonPressed(_ sender: UIButton) {
        if isDelayTimerStarted {
            resetAll()
        } else {
            if isTimerStarted {
                lapTimeArray.append("\(minuteLabel.text!):\(secondsLabel.text!),\(miliSecondsLabel.text!)")
                tableView.reloadData()
            } else {
                resetAll()
            }
        }
    }
    
    @objc func updateTimer() {
        totalSec += 0.01
        
        let min = Int(totalSec / 60)
        let sec = Int(totalSec) % 60
        let miliSec = Int(totalSec * 100) % 100
        
        let minStr = min < 10 ? "0\(min)" : "\(min)"
        let secStr = sec < 10 ? "0\(sec)" : "\(sec)"
        let miliSecStr = (miliSec / 10 == 0) ? "\(miliSec)0" : "\(miliSec)"
        
        minuteLabel.text = minStr
        secondsLabel.text = secStr
        miliSecondsLabel.text = miliSecStr
        let timeToRing = UserDefaults.standard.integer(forKey: "StopWatchTimeToRing")
        progressView.progress = (totalSec - Float(timeToRing * signals)) / Float(timeToRing)
        
        if progressView.progress == 1 {
            signals += 1
            longBeepPlayer.play()
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
