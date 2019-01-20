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
    
    var actionsList: Results<Action>?
    
    var countdownTimer: Timer!
    var totalTime = 11
    var currentAction = ""
    var currentActionDuration = 0
    var actions = [Action]()
    var currentActionIndex = 0
    var repCount = 0
    
    let actionList = UITableView()
    
//    let listActions = realm.objects(Action.self)
    
//    class Action {
//        var name: String = ""
//        var duration: Int = 0
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionList.frame = CGRect(x: 0, y: self.view.frame.height/3,
                                  width: self.view.frame.width, height: self.view.frame.height/4)
//        actionList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell") // for default style
        actionList.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        actionList.dataSource = self
        actionList.delegate = self
    
//        print(UITableViewCell.font)
        
        view.addSubview(actionList)
        
        loadActions()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionsList?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
//        cell.textLabel?.text = actionsList?[indexPath.row].name ?? "No Actions Added Yet"  // for default style
        cell.actionName = actionsList?[indexPath.row].name ?? "No Actions Added Yet"
        let duration = actionsList?[indexPath.row].duration ?? 0
        cell.duration = String(duration)
        return cell
    }
    
    // UPDATE ACTION
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let action = actionsList?[indexPath.row] {
            
            let alert = UIAlertController(title: "Edit Action", message:"", preferredStyle: .alert)
            
            alert.addTextField { (name) in
                name.placeholder = "Action Name"
                name.text = action.name
            }

            alert.addTextField(configurationHandler: { (duration) in
                duration.keyboardType = .numberPad
                duration.placeholder = "Action Duration"
                duration.text = String(action.duration)
            })

            // TODO: Refactor into update function
            
            let updateAlertAction = UIAlertAction(title: "Update", style: .default) { (updateAction) in

                let newAction = Action()
                newAction.name = (alert.textFields?[0].text)!
                newAction.duration = Int(alert.textFields?[1].text ?? "1")!

                do {
                    try self.realm.write {
                        action.name = newAction.name
                        action.duration = newAction.duration
                    }
                } catch {
                    print("Error updating action, \(error)")
                }
                
                tableView.reloadData();

            }

            alert.addAction(updateAlertAction)

            present(alert, animated: true, completion: nil)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadActions() {
        actionsList = realm.objects(Action.self)
        //actionList.reloadData();
    }

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
        
        let alert = UIAlertController(title: "Add New Action", message:"", preferredStyle: .alert)
        
        alert.addTextField { (name) in
            name.placeholder = "Add a new action"
        }
        
        alert.addTextField(configurationHandler: { (duration) in
            duration.keyboardType = .numberPad
            duration.placeholder = "Enter Duration"
        })
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newAction = Action()
            newAction.name = (alert.textFields?[0].text)!
            newAction.duration = Int(alert.textFields?[1].text ?? "1")!
            
            self.save(action: newAction)
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
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
        
        print("Calling reload data from save")
        actionList.reloadData()
    }
    
}

