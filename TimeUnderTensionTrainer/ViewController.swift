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

    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        let utterance = AVSpeechUtterance(string: "Ready. Begin.")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
        startTimer()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCall), userInfo: nil, repeats: true)
    }
    
    
    @objc func timerCall(){
        print("Timer executed")
    }
    
}

