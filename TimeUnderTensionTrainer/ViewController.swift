//
//  ViewController.swift
//  TimeUnderTensionTrainer
//
//  Created by Charles Griffin on 5/26/18.
//  Copyright © 2018 Charles Griffin. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = try! Realm()
    
    var countdownTimer: Timer!
    var totalTime = 11
    var currentAction = ""
    var currentActionDuration = 0
    var actions = [Action]()
    var currentActionIndex = 0
    var repCount = 0
    
    let listActions = ["Up","Pause","Down","Pause"]
    
//    class Action {
//        var name: String = ""
//        var duration: Int = 0
//    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listActions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = listActions[indexPath.row]
        return cell
    }

    

    @IBOutlet weak var actionList: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var repLabel: UILabel!
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
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Action", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newAction = Action()
            newAction.name = textField.text!
            newAction.duration = 10
            
            self.save(action: newAction)
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new action"
        }
        
        present(alert, animated: true, completion: nil)
        
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
                repCount += 1
                repLabel.text = "\(repCount)"
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
    
    func save(action: Action) {
        do {
            try realm.write {
                realm.add(action)
            }
        } catch {
            print("Error saving action\(action)")
        }
        
        
    }
    
}

