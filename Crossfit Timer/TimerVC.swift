//
//  TimerVC.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 18.05.18.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import Foundation
import MediaPlayer
import UserNotifications

class TimerVC: UIViewController {
    
    var longBeepPlayer: AVAudioPlayer!
    var shortBeepPlayer: AVAudioPlayer!
    var timer = Timer()
    var delayTimer = Timer()
    var isTimerWorking = false
    var isDelayTimerWorking = false
    var delaySignals = 0
    var signals = 0
    var delay: Int!
    var notificationIdentifires: [String] = []
    
    weak var countdownLabel: UILabel! {
        didSet {
            countdownLabel.text = "\(delay)"
            countdownLabel.layer.cornerRadius = countdownLabel.frame.size.height / 2
            countdownLabel.layer.masksToBounds = true
        }
    }
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti:)), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name: .UIApplicationWillEnterForeground, object: nil)
        setAudioPlayers()
    }
    
    //MARK: - Background/Foreground
    @objc func pauseWhenBackground(noti: Notification) {
        
    }
    
    @objc func willEnterForeground(noti: Notification) {
        
    }
    
    //MARK: - SetAudioPlayers
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
    
    //MARK: - SetDefaults
    func setDefaults() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            //StopWatch
            UserDefaults.standard.set(60, forKey: "StopWatchTimeToRing")
            //Tabata
            UserDefaults.standard.set(20, forKey: "TabataWork")
            UserDefaults.standard.set(10, forKey: "TabataRelax")
            UserDefaults.standard.set(3,  forKey: "TabataDelay")
            UserDefaults.standard.set(8,  forKey: "TabataRounds")
            //Rounds
            UserDefaults.standard.set(30, forKey: "RoundsModeTime")
            UserDefaults.standard.set(3,  forKey: "RoundsModeDelay")
            UserDefaults.standard.set(5,  forKey: "RoundsModeRounds")
            //Intervals
            UserDefaults.standard.set([30,20,10], forKey: "IntervalsModeIntervals")
            UserDefaults.standard.set(0,  forKey: "IntervalsModeDelay")
            UserDefaults.standard.set(4,  forKey: "IntervalsModeRounds")
        }
    }
    
    //MARK: - TIMER
    func startCountdown() {
        //delay = UserDefaults.standard.integer(forKey: "StopWatchDelay")
        if delay == 0 {
            countdownLabel.isHidden = true
            longBeepPlayer.play()
            startTimer()
        } else {
            isDelayTimerWorking = true
            countdownLabel.text = "\(delay!)"
            countdownLabel.isHidden = false
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
        //delay = UserDefaults.standard.integer(forKey: "StopWatchDelay")
        delaySignals += 1
        if delay - delaySignals < 0{
            delayTimer.invalidate()
            delaySignals = 0
            countdownLabel.isHidden = true
            isDelayTimerWorking = false
        } else if delay - delaySignals == 0 {
            longBeepPlayer.play()
            countdownLabel.text = "GO!"
            startTimer()
        } else {
            countdownLabel.text = "\(delay - delaySignals)"
            shortBeepPlayer.play()
        }
    }
    
    func startTimer () {
        isTimerWorking = true
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    
    @objc func updateTimer() {
    }
    
    //MARK: - FormateTime
    func getFormatedTime(from time: Double) -> (min: String, sec: String, miliSec: String) {
        let min = Int(time / 60)
        let sec = Int(time) % 60
        let miliSec = Int(time * 100) % 100
        
        let minStr = min < 10 ? "0\(min)" : "\(min)"
        let secStr = sec < 10 ? "0\(sec)" : "\(sec)"
        let miliSecStr = (miliSec / 10 == 0) ? "\(miliSec)0" : "\(miliSec)"
        return (minStr, secStr, miliSecStr)
    }
    
    //MARK: - Notifications
    func scheduleNotification(withIdentifire identifire: String,withTitle title: String, withText text: String, inSeconds seconds: TimeInterval) {
        let date = Date(timeIntervalSinceNow: seconds)
        print(Date())
        print(date)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        content.sound = UNNotificationSound.default()
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifire, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
        notificationIdentifires.append(identifire)
    }
    
    func removeNotifications(withIdentifires identifires: [String]) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifires)
    }
    
    //MARK: -
    func resetAll() {
        delaySignals = 0
        timer.invalidate()
        delayTimer.invalidate()
        countdownLabel.isHidden = true
        isDelayTimerWorking = false
        isTimerWorking = false
    }
    
    func presentAlert () {
        print("You've finished!!!")
    }
}
