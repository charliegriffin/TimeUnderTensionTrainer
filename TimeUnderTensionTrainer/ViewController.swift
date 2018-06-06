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
    var currentAction = ""
    var currentActionDuration = 0
    var actions = [Action]()
    var currentActionIndex = 0
    
    class Action {
        var name: String = ""
        var duration: Int = 0
    }

    @IBOutlet weak var timerLabel: UILabel!
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        
        let firstAction = Action()
        actions.append(firstAction)
        firstAction.name = "Down"
        firstAction.duration = 4
        let secondAction = Action()
        secondAction.name = "Up"
        secondAction.duration = 2
        actions.append(secondAction)
        currentAction = firstAction.name
        currentActionDuration = firstAction.duration
        startTimer()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func startTimer() {
        print(currentAction)
        totalTime = currentActionDuration
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        timerLabel.text = "\(totalTime)"
        if(totalTime == currentActionDuration){
            print("Speaking current action")
            speakCount(phrase: currentAction)
        } else if (totalTime != 0) {
            speakCount(phrase: String(totalTime))
        }
        
        if totalTime > 1 {
            totalTime -= 1
        } else {
            // Next Action
            if(currentActionIndex < (actions.count - 1)){
                currentActionIndex += 1
            } else {
                currentActionIndex = 0
            }
            currentAction = actions[currentActionIndex].name
            currentActionDuration = actions[currentActionIndex].duration
            totalTime = currentActionDuration
            //endTimer()
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

