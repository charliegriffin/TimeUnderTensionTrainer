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
import SwipeCellKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = try! Realm()
    
    var actionsList: Results<Action>?
    
    var countdownTimer: Timer!
    var totalTime = 11
    var currentAction = ""
    var currentActionDuration = 0
    var currentActionIndex = 0
    var repCount = 0
    
    let startAction = "Starting in 10 seconds"
    let startActionDuration = 11
    
    // state variables
    var timerRunning = false
    
    // MARK: Initalize UI Elements
    
    let actionList = UITableView()
    let addActionButton = UIButton(type: .contactAdd)
    let startTimerButton = UIButton(type: .system)
    let repLabel = UILabel()
    let timerLabel = UILabel()
    
//    let listActions = realm.objects(Action.self)
    
//    class Action {
//        var name: String = ""
//        var duration: Int = 0
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionList.frame = CGRect(x: 0, y: self.view.frame.height/3,
                                  width: self.view.frame.width, height: self.view.frame.height/2)
//        actionList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell") // for default style
        actionList.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        actionList.dataSource = self
        actionList.delegate = self
    
//        print(UITableViewCell.font)
        
        addActionButton.frame = CGRect(x: self.view.frame.width*0.9, y: self.view.frame.height*0.95, width: 22, height: 22)
        addActionButton.tintColor = .black
        addActionButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        
        let startTextWidth = CGFloat(100);
        let startTextHeight = CGFloat(100);
        
        startTimerButton.frame = CGRect(x: (self.view.frame.width-startTextWidth)*0.5, y: self.view.frame.height*0.9, width: startTextWidth, height: startTextHeight)
        startTimerButton.setTitle("Start", for: .normal)
        startTimerButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 40)
        startTimerButton.setTitleColor(.black, for: .normal)
        startTimerButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
        
        let repLabelWidth = CGFloat(self.view.frame.width*0.9);
        let repLabelHeight = CGFloat(100);
        
        repLabel.frame = CGRect(x: (self.view.frame.width-repLabelWidth)*0.5, y: self.view.frame.height*0.1, width: repLabelWidth, height: repLabelHeight)
        repLabel.textAlignment = .center
        repLabel.text = "Press Start"
        repLabel.font = UIFont(name: "Helvetica Neue", size: 40)
        //repLabel.textColor = .white
        
        let timerLabelWidth = CGFloat(self.view.frame.width*0.5);
        let timerLabelHeight = CGFloat(100);
        
        timerLabel.frame = CGRect(x: (self.view.frame.width-timerLabelWidth)*0.5, y: self.view.frame.height*0.2, width: timerLabelWidth, height: timerLabelHeight)
        timerLabel.textAlignment = .center
        timerLabel.text = "0"
        timerLabel.font = UIFont(name: "Helvetica Neue", size: 40)
        //timerLabel.textColor = .white
        
        
        view.addSubview(actionList)
        view.addSubview(addActionButton)
        view.addSubview(startTimerButton)
        view.addSubview(repLabel)
        view.addSubview(timerLabel)
        
        loadActions()
        
        actionList.rowHeight = 60.0
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
        
        cell.delegate = self
        
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

            // TODO: Refactor into update function
            
            let updateAlertAction = UIAlertAction(title: "Update", style: .default) { (updateAction) in

                if(alert.textFields?[0].text! != ""){
                    let newAction = Action()
                    newAction.name = (alert.textFields?[0].text)!
                    newAction.duration = alert.textFields?[1].text != "" ? Int(alert.textFields?[1].text ?? "1")! : 1

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

            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)

            alert.addAction(updateAlertAction)
            alert.addAction(cancel)
            
            alert.addTextField(configurationHandler: { (duration) in
                duration.keyboardType = .numberPad
                duration.placeholder = "Action Duration"
                duration.text = String(action.duration)
                self.validateNumInput(action: updateAlertAction, input: duration)
            })

            present(alert, animated: true, completion: nil)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadActions() {
        actionsList = realm.objects(Action.self).sorted(byKeyPath: "index", ascending: true)
        //actionList.reloadData();
    }

    @objc func startButtonPressed(_ sender: UIButton) {
        
        
//        let firstAction = Action()
//        actions.append(firstAction)
//        firstAction.name = "Down"
//        firstAction.duration = 4
//        let secondAction = Action()
//        secondAction.name = "Up"
//        secondAction.duration = 2
//        actions.append(secondAction)
        if(!timerRunning){
            // TODO: add time to get ready
            //"Starting exercise in 10 seconds"
            //"3, 2, 1 Begin"
            
            currentAction = startAction
            currentActionDuration = startActionDuration
            //            currentAction = actionsList?[0].name ?? ""
//            currentActionDuration = actionsList?[0].duration ?? 10
            startTimer()
            timerRunning = true;
            startTimerButton.setTitle("Stop", for: .normal);
        } else {
            endTimer()
            timerRunning = !timerRunning;
            startTimerButton.setTitle("Start", for: .normal);
        }
        
        
    }
    
    @objc func addButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Add New Action", message:"", preferredStyle: .alert)
        
        alert.addTextField { (name) in
            name.placeholder = "Add a new action"
        }
        
        
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            
            if(alert.textFields?[0].text! != ""){
                let newAction = Action()
                newAction.name = (alert.textFields?[0].text)!
                newAction.duration = alert.textFields?[1].text != "" ? Int(alert.textFields?[1].text ?? "1")! : 1
                newAction.index = (self.actionsList?.count ?? 0)
                self.save(action: newAction)
            }
            
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        alert.addTextField(configurationHandler: { (duration) in
            duration.keyboardType = .numberPad
            duration.placeholder = "Enter Duration"
            duration.text = ""
            self.validateNumInput(action: action, input: duration)
        })
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func validateNumInput(action: UIAlertAction, input: UITextField) {
        action.isEnabled = false
        let regex = try! NSRegularExpression(pattern: "^[0-9]*$", options: .caseInsensitive)

        var isValidNum = input.text!.count > 0  // preserves edit behavior while starting false on add
        action.isEnabled = isValidNum
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: input, queue: OperationQueue.main) { (notification) in
            isValidNum = regex.firstMatch(in: input.text!, options: [], range: NSRange(location: 0, length: input.text!.count)) != nil
            isValidNum = isValidNum && input.text!.count > 0
            action.isEnabled = isValidNum
        }
    }
    
    func startTimer() {
        
        
        
        print(currentAction)
        totalTime = currentActionDuration
        repCount = 0
        repLabel.text = "\(repCount)"
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        
        // TODO: this is in desparate need of a refactor
        timerLabel.text = "\(totalTime)"
        
        if(currentAction == startAction){
            readyCountdown()
        } else {
            countdown()
        }
    }
    
    func readyCountdown() {
        if(totalTime == currentActionDuration){
            speakCount(phrase: currentAction)
        } else if (totalTime == 5){
            speakCount(phrase: "Ready?")
        } else if (totalTime < 4){
            speakCount(phrase: String(totalTime))
        }
        
        if totalTime > 1 {
            totalTime -= 1
        } else {
            currentAction = "Begin"
            currentActionDuration = 1
            currentActionIndex = -1
        }
    }
    
    
    // TODO: split into 2 function, read countdown and update countdown
    func countdown() {
        //        print("current action duration", currentActionDuration)
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
            if(currentActionIndex < ((actionsList?.count)! - 1)){
                currentActionIndex += 1
            } else {
                currentActionIndex = 0
                repCount += 1
                repLabel.text = "\(repCount)"
            }
            currentAction = actionsList![currentActionIndex].name
            currentActionDuration = actionsList![currentActionIndex].duration
            totalTime = currentActionDuration
        }
        //endTimer()
    }
    
    
    func endTimer() {
        countdownTimer.invalidate()
        currentActionIndex = 0
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
    
    
    
    func deleteAction(action: Action) {
        do {
            try realm.write {
                realm.delete(action)
            }
            reindexActions()
        } catch {
            print("Error deleting action\(action)")
        }
//        actionList.reloadData()
    }
    
    func reindexActions() {
        
        for index in (actionsList?.indices)! {
            guard let remainingAction = actionsList?[index] else {
                print("Error finding action at position \(index) for reindexing")
                return
            }
            // update index on action
            do {
                try self.realm.write {
                    remainingAction.index = index
                }
            } catch {
                print("Error reindexing actions, \(error)")
            }
        }
    }
    
}

//MARK: - Swipe Cell Delegate Methods

// TODO: Refactor into super class

extension ViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if let actionToDelete = self.actionsList?[indexPath.row] {
                self.deleteAction(action: actionToDelete)
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}
