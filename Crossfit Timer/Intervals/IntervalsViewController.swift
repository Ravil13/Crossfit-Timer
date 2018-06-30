//
//  IntervalsViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 08.04.18.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

//UserDefaults.standard.set([30,20,10], forKey: "IntervalsModeIntervals")
//UserDefaults.standard.set(0,  forKey: "IntervalsModeDelay")
//UserDefaults.standard.set(4,  forKey: "IntervalsModeRounds")

import UIKit

class IntervalsViewController: TimerVC, UITableViewDataSource, UITableViewDelegate {

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
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentRound = 1
    var currentInterval = 1
    var rounds = UserDefaults.standard.integer(forKey: "IntervalsModeRounds")
    var intervals = [0.0, 0,0]//UserDefaults.standard.array(forKey: "IntervalsModeIntervals") as! [Double]
    var totalRounds = 12
    var remainigTimes = [0.0, 0,0]//UserDefaults.standard.array(forKey: "IntervalsModeIntervals") as! [Double]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalRounds = rounds * intervals.count
        intervals = UserDefaults.standard.array(forKey: "IntervalsModeIntervals") as! [Double]
        remainigTimes = intervals
        
        tableView.dataSource = self
        tableView.delegate = self
        updateUI()
        updateRoundsLabel()
    }
    
    //MARK: Background/Foreground
    @objc override func pauseWhenBackground(noti: Notification) {
        timer.invalidate()
        UserDefaults.standard.set(Date(), forKey: "IntervalsModeSavedDate")
        setNotifications()
    }
    
    @objc override func willEnterForeground(noti: Notification) {
        removeNotifications(withIdentifires: notificationIdentifires)
        notificationIdentifires.removeAll()
        if isTimerWorking {
            if let savedDate = UserDefaults.standard.object(forKey: "IntervalsModeSavedDate") as? Date{
                var difSec = savedDate.timeIntervalSinceNow * -1
                print(Date())
                print("dif is \(difSec)")
                difSec -= remainigTimes[currentInterval - 1]
                
                if difSec  > 0 {
                    currentInterval += 1
                    if currentInterval - 1 == remainigTimes.count {
                        currentRound += 1
                        currentInterval = 1
                    }
                }
                
                while difSec > 0 {
                    difSec -= intervals[currentInterval - 1]
                    if difSec  > 0 {
                        currentInterval += 1
                        if currentInterval - 1 == remainigTimes.count {
                            currentRound += 1
                            currentInterval = 1
                        }
                    }
                }
                
                remainigTimes[currentInterval - 1] = difSec * -1
                startTimer()
                updateRoundsLabel()
                tableView.reloadData()
                updateUI()
            }
        }
    }
    
    //MARK: - Notifications
    func setNotifications() {
        if isTimerWorking {
            var time = remainigTimes[currentInterval-1]
            scheduleNotification(withIdentifire: "Intervals0", withTitle: "Раунд \(currentRound)", withText: "Интервал \(currentInterval) завершен", inSeconds: time)
            for index in currentInterval ..< remainigTimes.count {
                time += remainigTimes[index]
                scheduleNotification(withIdentifire: "Intervals\(notificationIdentifires.count)", withTitle: "Раунд\(currentRound)", withText: "Интервал \(index+1) завершен", inSeconds: time)
            }
            
            for round in currentRound ..< rounds {
                for i in 0 ..< intervals.count {
                    time += intervals[i]
                    scheduleNotification(withIdentifire: "Intervals\(notificationIdentifires.count)", withTitle: "Раунд \(round+1)", withText: "Интервал \(i+1) завершен", inSeconds: time)
                }
            }
        }
    }
    
    //MARK: - TIMER
    override func startCountdown() {
        delay = UserDefaults.standard.integer(forKey: "IntervalsModeDelay")
        super.startCountdown()
    }
    
    override func countdown() {
        delay = UserDefaults.standard.integer(forKey: "IntervalsModeDelay")
        super.countdown()
    }
    
    override func startTimer() {
        super.startTimer()
    }
    
    override func updateTimer() {
        super.updateTimer()
        if (currentRound-1) * intervals.count + currentInterval <= totalRounds {
            if currentInterval <= intervals.count {
                remainigTimes[currentInterval-1] -= 0.01
                progressView.progress = Float(((intervals[currentInterval-1] - remainigTimes[currentInterval-1])) / intervals[currentInterval-1])
                if remainigTimes[currentInterval-1] <= 0 {
                    longBeepPlayer.play()
                    currentInterval += 1
                    updateRoundsLabel()
                }
            }
            if  currentInterval > intervals.count {
                print("конец \(currentRound) раунда")
                currentRound += 1
                currentInterval = 1
                remainigTimes = intervals
            }
        } else {
            presentAlert()
            resetAll()
        }
        updateUI()
    }
    
    func updateRoundsLabel() {
        let currentTotalInterval = (currentRound-1) * intervals.count + currentInterval
        if currentTotalInterval > totalRounds {
            roundsLabel.text = "Интервал \(currentTotalInterval - 1)/\(totalRounds)"
        } else {
            roundsLabel.text = "Интервал \(currentTotalInterval)/\(totalRounds)"
        }
    }
    
    func updateUI() {
        let formatedTime = getFormatedTime(from: remainigTimes[currentInterval-1])
        
        minLabel.text = formatedTime.min
        secLabel.text = formatedTime.sec
        miliSecLabel.text = formatedTime.miliSec
        
        let indexPath = IndexPath(row: currentInterval-1, section: currentRound-1)
        let ft = getFormatedTime(from: remainigTimes[indexPath.row])
        let str = "\(ft.min):\(ft.sec),\(ft.miliSec)"
        if currentRound <= rounds {
            tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = str
        }
    }
    
    override func resetAll() {
        super.resetAll()
        removeNotifications(withIdentifires: notificationIdentifires)
        currentRound = 1
        currentInterval = 1
        roundsLabel.text = "Раунд \(currentRound * currentInterval)/\(totalRounds)"
        progressView.progress = 0
        startStopButton.setTitle("Старт", for: .normal)
        remainigTimes = intervals
        navigationController?.navigationBar.isUserInteractionEnabled = true
        navigationController?.navigationBar.tintColor = UIColor.white
        resetSkipButton.setTitle("Сброс", for: .normal)
        resetSkipButton.setBackgroundImage(UIImage(named: "Reset btn"), for: .normal)
        resetSkipButton.isEnabled = false
        tableView.reloadData()
        updateRoundsLabel()
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
                remainigTimes[currentInterval-1] = 0.00001
                tableView.reloadData() //иначе в tableView остается время пропуска
            } else { // Сбросить
                resetAll()
            }
        }
    }
}

extension IntervalsViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return rounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = "Интервал \(indexPath.row + 1)"
        cell.detailTextLabel?.textColor = .white
        if (indexPath.section+1 < currentRound) ||  (indexPath.section+1 == currentRound && indexPath.row+1 < currentInterval){
            cell.detailTextLabel?.text = "00:00,00"
        } else if indexPath.section+1 == currentRound {
            let ft = getFormatedTime(from: remainigTimes[indexPath.row])
            let str = "\(ft.min):\(ft.sec),\(ft.miliSec)"
            cell.detailTextLabel?.text = str
        } else {
            let ft = getFormatedTime(from: intervals[indexPath.row])
            let str = "\(ft.min):\(ft.sec),\(ft.miliSec)"
            cell.detailTextLabel?.text = str
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(26)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let height = CGFloat(26)
        let frame = CGRect(x: 0, y: 0, width: (self.tableView.frame.size.width), height: height)
        let view = UIView(frame: frame)
        view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: 150, height: 26))
        label.text = "Раунд \(section + 1)"
        label.textColor = .white
        label.backgroundColor = .clear
        view.addSubview(label)
        return view
    }
}
