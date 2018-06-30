//
//  RoundsViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 08.04.18.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit

class RoundsViewController: TimerVC {
    
    @IBOutlet weak var roundsLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    @IBOutlet weak var miliSecLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var resetSkipButton: UIButton!
    @IBOutlet override weak var countdownLabel: UILabel! {
        didSet { }
    }
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var currentRound = 1
    var remainingTotalSec = Double(UserDefaults.standard.integer(forKey: "RoundsModeTime"))
    var rounds = UserDefaults.standard.integer(forKey: "RoundsModeRounds")
    var time  = Double(UserDefaults.standard.integer(forKey: "RoundsModeTime"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        remainingTotalSec = Double(UserDefaults.standard.integer(forKey: "RoundsModeTime"))
        rounds = UserDefaults.standard.integer(forKey: "RoundsModeRounds")
        time  = Double(UserDefaults.standard.integer(forKey: "RoundsModeTime"))
        updateUI()
    }
    
    //MARK: Background/Foreground
    @objc override func pauseWhenBackground(noti: Notification) {
        timer.invalidate()
        UserDefaults.standard.set(Date(), forKey: "RoundsModeSavedDate")
        UserDefaults.standard.set(remainingTotalSec, forKey: "RoundsModeSavedTime")
        setNotifications()
    }
    
    @objc override func willEnterForeground(noti: Notification) {
        removeNotifications(withIdentifires: notificationIdentifires)
        notificationIdentifires.removeAll()
        if isTimerWorking {
            if let savedDate = UserDefaults.standard.object(forKey: "RoundsModeSavedDate") as? Date{
                var difSec = savedDate.timeIntervalSinceNow * -1
                print(Date())
                print("dif is \(difSec)")
                
                let savedTime = UserDefaults.standard.double(forKey: "RoundsModeSavedTime")
                if difSec - savedTime > 0 {
                    currentRound += 1
                }
                difSec -= savedTime
                
                while difSec > 0 {
                    if difSec - time > 0 {
                        currentRound += 1
                    }
                    difSec -= time
                }
                remainingTotalSec = difSec * -1
                startTimer()
                updateUI()
            }
        }
    }
    
    
    //MARK: - Notifications
    func setNotifications() {
        if isTimerWorking {
            scheduleNotification(withIdentifire: "RoundsMode0", withTitle: "Раунд \(currentRound)", withText: "Завершен", inSeconds: remainingTotalSec)
            let remainingRounds = rounds - currentRound
            if remainingRounds > 1 {
                for i in 1...remainingRounds-1 {
                    let timeToNextNotification = time * Double(i) + remainingTotalSec
                    scheduleNotification(withIdentifire: "RoundsMode\(i)", withTitle: "Раунд \(currentRound + i)", withText: "Завершен", inSeconds: timeToNextNotification)
                }
            }
            let timeToLastNotification = time * Double(remainingRounds) + remainingTotalSec
            scheduleNotification(withIdentifire: "RoundsMode\(remainingRounds)", withTitle: "Раунды", withText: "Полседний раунд завершен", inSeconds: timeToLastNotification)
        }
    }
    
    //MARK: - TIMER
    override func startCountdown() {
        delay = UserDefaults.standard.integer(forKey: "RoundsModeDelay")
        super.startCountdown()
    }
    
    override func countdown() {
        delay = UserDefaults.standard.integer(forKey: "RoundsModeDelay")
        super.countdown()
    }
    
    override func startTimer() {
        super.startTimer()
    }
    
    override func updateTimer() {
        super.updateTimer()
        if currentRound <= rounds {
            remainingTotalSec -= 0.01
            progressView.progress = Float(((time - remainingTotalSec)) / time)
            if remainingTotalSec <= 0 {
                longBeepPlayer.play()
                currentRound += 1
                remainingTotalSec = time
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
        let formatedTime = getFormatedTime(from: remainingTotalSec)
        
        minLabel.text = formatedTime.min
        secLabel.text = formatedTime.sec
        miliSecLabel.text = formatedTime.miliSec
    }
    
    override func resetAll() {
        super.resetAll()
        removeNotifications(withIdentifires: notificationIdentifires)
        currentRound = 1
        roundsLabel.text = "Раунд \(currentRound)/\(rounds)"
        progressView.progress = 0
        startStopButton.setTitle("Старт", for: .normal)
        remainingTotalSec = time
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
                startStopButton.setTitle("Стоп", for: UIControlState.normal)
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
                remainingTotalSec = 0.00001
            } else { // Сбросить
                resetAll()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension RoundsViewController: RoundsSettingsDelegate {
    func changeTime(sec: Int) {
        time = Double(sec)
        remainingTotalSec = Double(sec)
        updateUI()
    }
    
    func changeRounds(rounds: Int) {
        self.rounds = rounds
        updateUI()
    }
    
    func changeDelay(sec: Int) {
        self.delay = sec
        updateUI()
    } 
}
