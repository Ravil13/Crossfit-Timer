//
//  TabataViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 08.04.18.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit
import MediaPlayer

class TabataViewController: UIViewController {
    
    @IBOutlet weak var workMinLabel: UILabel!
    @IBOutlet weak var WorkSecLabel: UILabel!
    @IBOutlet weak var workMiliSecLabel: UILabel!
    @IBOutlet weak var relaxMinLabel: UILabel!
    @IBOutlet weak var relaxSecLabel: UILabel!
    @IBOutlet weak var relaxMiliSecLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var resetLapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
        setAudioPlayers()
    }
    
    var longBeepPlayer: AVAudioPlayer!
    var shortBeepPlayer: AVAudioPlayer!
    var timer = Timer()
    var delayTimer = Timer()
    var isTimerStarted = false
    var isDelayTimerStarted = false
    var signals = 0
    var delay = UserDefaults.standard.integer(forKey: "TabatDelay")
    
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
    
    func setDefaults() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            UserDefaults.standard.set(60, forKey: "StopWatchTimeToRing")
        }
    }
    
    @IBAction func startStopButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        
    }
}
