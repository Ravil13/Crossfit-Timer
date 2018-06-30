//
//  TabataViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 08.04.18.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit
import MediaPlayer
import UserNotifications

class TabataViewController: TimerVC {
    
    @IBOutlet weak var roundsLabel: UILabel!
    @IBOutlet weak var workMinLabel: UILabel!
    @IBOutlet weak var workSecLabel: UILabel!
    @IBOutlet weak var workMiliSecLabel: UILabel!
    @IBOutlet weak var relaxMinLabel: UILabel!
    @IBOutlet weak var relaxSecLabel: UILabel!
    @IBOutlet weak var relaxMiliSecLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var resetSkipButton: UIButton!
    @IBOutlet override weak var countdownLabel: UILabel! {
        didSet { }
    }
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid // ??
    var workRemainingTotalSec: Double!
    var relaxRemainingTotalSec: Double!
    var isWorkTime  = true
    var currentRound = 1
    var rounds = UserDefaults.standard.integer(forKey: "TabataRounds")
    var tabataWorkTime  = Double(UserDefaults.standard.integer(forKey: "TabataWork"))
    var tabataRelaxTime = Double(UserDefaults.standard.integer(forKey: "TabataRelax"))
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
        workRemainingTotalSec = Double(UserDefaults.standard.integer(forKey: "TabataWork"))
        relaxRemainingTotalSec = Double(UserDefaults.standard.integer(forKey: "TabataRelax"))
        rounds = UserDefaults.standard.integer(forKey: "TabataRounds")
        updateUI()
    }
    
    //MARK: Background/Foreground
    @objc override func pauseWhenBackground(noti: Notification) {
        timer.invalidate()
        UserDefaults.standard.set(Date(), forKey: "TabataSavedDate")
        UserDefaults.standard.set(workRemainingTotalSec, forKey: "TabataSavedWork")
        UserDefaults.standard.set(relaxRemainingTotalSec, forKey: "TabataSavedRelax")
        print("\(Date()) ApplicationDidEnterBackground")
        setNotifications()
    }
    
    @objc override func willEnterForeground(noti: Notification) {
        removeNotifications(withIdentifires: notificationIdentifires)
        notificationIdentifires.removeAll()
        if isTimerWorking {
            if let savedDate = UserDefaults.standard.object(forKey: "TabataSavedDate") as? Date{
                var difSec = savedDate.timeIntervalSinceNow * -1
                print(Date())
                print("dif is \(difSec)")
                var i = 0
                
                while (difSec > 0) {
                    if i == 0 {
                        let savedWork = UserDefaults.standard.double(forKey: "TabataSavedWork")
                        difSec -= savedWork
                    } else if i == 1 {
                        let savedRelax = UserDefaults.standard.double(forKey: "TabataSavedRelax")
                        if difSec - savedRelax > 0 {
                            currentRound += 1
                        }
                        difSec -= savedRelax
                    } else if (i % 2) == 0 {
                        difSec -= tabataWorkTime
                    } else {
                        difSec -= tabataRelaxTime
                        currentRound += 1
                    }
                    i += 1
                }
                i -= 1
                if (i % 2) == 0 {
                    workRemainingTotalSec = difSec * -1
                    relaxRemainingTotalSec = tabataRelaxTime
                    isWorkTime = true
                } else {
                    workRemainingTotalSec = 0.000001
                    relaxRemainingTotalSec = difSec * -1
                    isWorkTime = false
                }
                startTimer()
                updateUI()
            }
        }
    }
    
    
    //MARK: - Notifications
    func setNotifications() {
        if isTimerWorking {
            if isWorkTime {
                scheduleNotification(withIdentifire: "work0", withTitle: "Табата", withText: "Время отдыха", inSeconds: workRemainingTotalSec)
            }
            scheduleNotification(withIdentifire: "relax0", withTitle: "Табата", withText: "Время работать", inSeconds: relaxRemainingTotalSec + workRemainingTotalSec)
            let remainingRounds = rounds - currentRound
            if remainingRounds > 1 {
                for i in 1...remainingRounds-1 {
                    let work = (tabataWorkTime * Double(i) + tabataRelaxTime * Double(i - 1)) + workRemainingTotalSec + relaxRemainingTotalSec
                    let relax = ((tabataRelaxTime + tabataWorkTime) * Double(i)) + workRemainingTotalSec + relaxRemainingTotalSec
                    scheduleNotification(withIdentifire: "work\(i)", withTitle: "Табата", withText: "Время отдыха", inSeconds: TimeInterval(work))
                    scheduleNotification(withIdentifire: "relax\(i)", withTitle: "Табата", withText: "Время работать", inSeconds: TimeInterval(relax))
                }
            }
            let work = (tabataWorkTime * Double(remainingRounds) + tabataRelaxTime * Double(remainingRounds - 1)) + workRemainingTotalSec + relaxRemainingTotalSec
            let relax = ((tabataRelaxTime + tabataWorkTime) * Double(remainingRounds)) + workRemainingTotalSec + relaxRemainingTotalSec
            scheduleNotification(withIdentifire: "work\(remainingRounds)", withTitle: "Табата", withText: "Время отдыха", inSeconds: TimeInterval(work))
            scheduleNotification(withIdentifire: "relax\(remainingRounds)", withTitle: "Табата", withText: "Последний раунд завершен", inSeconds: TimeInterval(relax))
        }
    }
    
    //MARK: - TIMER
    override func startCountdown() {
        delay = UserDefaults.standard.integer(forKey: "TabataDelay")
        super.startCountdown()
    }
    
    override func countdown() {
        delay = UserDefaults.standard.integer(forKey: "TabataDelay")
        super.countdown()
    }
    
    override func startTimer() {
        super.startTimer()
        startStopButton.setTitle("Стоп", for: UIControlState.normal)
    }
    
    override func updateTimer() {
        super.updateTimer()
        if currentRound <= rounds {
            if isWorkTime {
                workRemainingTotalSec!  -= 0.01
                progressView.progress = Float(((tabataWorkTime - workRemainingTotalSec)) / tabataWorkTime)
                if workRemainingTotalSec <= 0 {
                    isWorkTime  = false
                    progressView.tintColor = .green
                    longBeepPlayer.play()
                }
            } else {
                relaxRemainingTotalSec! -= 0.01
                progressView.progress = Float(((tabataRelaxTime - relaxRemainingTotalSec)) / tabataRelaxTime)
                if relaxRemainingTotalSec <= 0 {
                    isWorkTime  = true
                    progressView.tintColor = .orange
                    workRemainingTotalSec = tabataWorkTime
                    relaxRemainingTotalSec = tabataRelaxTime
                    longBeepPlayer.play()
                    currentRound += 1
                }
            }
        } else {
            presentAlert()
            resetAll()
        }
        updateUI()
    }
    
    func updateUI() {
        if currentRound > rounds {
            roundsLabel.text = "Раунд \(currentRound-1)/\(rounds)"
        } else {
            roundsLabel.text = "Раунд \(currentRound)/\(rounds)"
        }
        let workTime = getFormatedTime(from: workRemainingTotalSec)
        
        workMinLabel.text = workTime.min
        workSecLabel.text = workTime.sec
        workMiliSecLabel.text = workTime.miliSec
        
        let relaxTime = getFormatedTime(from: relaxRemainingTotalSec)
        
        relaxMinLabel.text = relaxTime.min
        relaxSecLabel.text = relaxTime.sec
        relaxMiliSecLabel.text = relaxTime.miliSec
    }
    
    override func resetAll() {
        super.resetAll()
        removeNotifications(withIdentifires: notificationIdentifires)
        currentRound = 1
        isWorkTime = true
        roundsLabel.text = "Раунд \(currentRound)/\(rounds)"
        progressView.progress = 0
        progressView.tintColor = .orange
        startStopButton.setTitle("Старт", for: .normal)
        workRemainingTotalSec = tabataWorkTime
        relaxRemainingTotalSec = tabataRelaxTime
        navigationController?.navigationBar.isUserInteractionEnabled = true
        navigationController?.navigationBar.tintColor = UIColor.white
        resetSkipButton.setTitle("Сброс", for: .normal)
        resetSkipButton.setBackgroundImage(UIImage(named: "Reset btn"), for: .normal)
        resetSkipButton.isEnabled = false
        updateUI()
    }
    
    //MARK: - Actions
    @IBAction func startStopButtonPressed(_ sender: UIButton) {
        resetSkipButton.isEnabled = true
        if isDelayTimerWorking {
            resetAll()
        } else {
            if isTimerWorking {
                timer.invalidate()
                isTimerWorking = false
                startStopButton.setTitle("Дальше", for: .normal)
                resetSkipButton.setTitle("Сброс", for: .normal)
                resetSkipButton.setBackgroundImage(UIImage(named: "Reset btn"), for: .normal)
            } else {
                if startStopButton.titleLabel?.text == "Дальше" {
                    startTimer()
                } else {
                    startCountdown()
                }
                resetSkipButton.setBackgroundImage(UIImage(named: "Pause btn"), for: .normal)
                resetSkipButton.setTitle("Пропуск", for: .normal)
            }
            navigationController?.navigationBar.isUserInteractionEnabled = false
            navigationController?.navigationBar.tintColor = UIColor.lightGray
        }
    }
    
    @IBAction func resetSkipButtonPressed(_ sender: UIButton) {
        if isDelayTimerWorking {
            resetAll()
        } else {
            if isTimerWorking {// Пропустить
                if isWorkTime {
                    workRemainingTotalSec = 0.00001
                } else {
                    relaxRemainingTotalSec = 0.00001
                }
            } else { // Сбросить
                resetAll()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - TabataSettingsDelegate
extension TabataViewController: TabataSettingsDelegate {
    func changeWorkTime(sec: Int) {
        workRemainingTotalSec = Double(sec)
        tabataWorkTime  = Double(UserDefaults.standard.integer(forKey: "TabataWork"))
        updateUI()
    }
    
    func changeRelaxTimer(sec: Int) {
        relaxRemainingTotalSec = Double(sec)
        tabataRelaxTime = Double(UserDefaults.standard.integer(forKey: "TabataRelax"))
        updateUI()
    }
    
    func changeRounds(rounds: Int) {
        self.rounds = rounds
        updateUI()
    }
    
    func changeDelay(sec: Int) {
        delay = sec
        updateUI()
    }
}
