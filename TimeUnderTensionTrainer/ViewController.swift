//
//  ViewController.swift
//  TimeUnderTensionTrainer
//
//  Created by Charles Griffin on 5/26/18.
//  Copyright © 2018 Charles Griffin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var countdownTimer: Timer!
    var totalTime = 11
    
    class Action {
        var name: String = ""
        var duration: Int = 0
    }

    @IBOutlet weak var timerLabel: UILabel!
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        let firstAction = Action()
        firstAction.name = "Down"
        firstAction.duration = 4
        startTimer(action: firstAction)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func startTimer(action: Action) {
        print(action.name)
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        speakCount(phrase: String(totalTime))
        timerLabel.text = "\(totalTime)"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
    }
    
    func speakCount(phrase: String) {
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 1

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
}

