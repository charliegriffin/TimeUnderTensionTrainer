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
    let currentActionLabel = UILabel()
    
//    let listActions = realm.objects(Action.self)
    
//    class Action {
//        var name: String = ""
//        var duration: Int = 0
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionList.frame = CGRect(x: 0, y: self.view.frame.height*0.4,
                                  width: self.view.frame.width, height: self.view.frame.height/2)
//        actionList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell") // for default style
        actionList.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        actionList.dataSource = self
        actionList.delegate = self
        
        addActionButton.frame = CGRect(x: self.view.frame.width*0.9, y: self.view.frame.height*0.95, width: 22, height: 22)
        addActionButton.tintColor = .black
        addActionButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        
        let startTextWidth = CGFloat(100);
        let startTextHeight = CGFloat(100);
        
        startTimerButton.frame = CGRect(x: (self.view.frame.width-startTextWidth)*0.5, y: (self.view.frame.height-startTextHeight/2)*0.95, width: startTextWidth, height: startTextHeight)
        startTimerButton.setTitle("Start", for: .normal)
        startTimerButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 40)
        startTimerButton.setTitleColor(.black, for: .normal)
        startTimerButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
        //startTimerButton.isEnabled = !(!actionsList.count)
        
        let timerLabelWidth = CGFloat(self.view.frame.width);
        let timerLabelHeight = CGFloat(100);
        let timerFontSize = self.view.frame.width/3.5
        let timerPadding = (90 + 0.1*self.view.frame.height)/2
        
        timerLabel.frame = CGRect(x: (self.view.frame.width-timerLabelWidth)*0.5, y: self.view.frame.height*0.15, width: timerLabelWidth, height: timerLabelHeight)
        timerLabel.textAlignment = .center
        timerLabel.text = "00:00"
        timerLabel.font = UIFont(name: "Helvetica Neue", size: timerFontSize)
        
        let repLabelWidth = CGFloat(self.view.frame.width*0.9);
        let repLabelHeight = CGFloat(100);
        let repLabelFontSize = 0.3*timerFontSize
        
        repLabel.frame = CGRect(x: (self.view.frame.width-repLabelWidth)*0.5, y: self.view.frame.height*0.15 - timerPadding, width: repLabelWidth, height: repLabelHeight)
        repLabel.textAlignment = .center
        repLabel.text = "Reps: 0"
        repLabel.font = UIFont(name: "Helvetica Neue", size: repLabelFontSize)
        //repLabel.textColor = .white
        
        let currentActionLabelWidth = CGFloat(self.view.frame.width*0.9);
        let currentActionLabelHeight = CGFloat(100);
        let currentActionFontSize = 0.3*timerFontSize;
        
        currentActionLabel.frame = CGRect(x: (self.view.frame.width-currentActionLabelWidth)*0.5, y: self.view.frame.height*0.15 + timerPadding, width: currentActionLabelWidth, height: currentActionLabelHeight)
        currentActionLabel.textAlignment = .center
        currentActionLabel.text = "Press Start"
        currentActionLabel.font = UIFont(name: "Helvetica Neue", size: currentActionFontSize)
        
        
        view.addSubview(actionList)
        view.addSubview(addActionButton)
        view.addSubview(startTimerButton)
        view.addSubview(repLabel)
        view.addSubview(timerLabel)
        view.addSubview(currentActionLabel)
        
        loadActions()
        
        let rowHeight = (self.view.frame.height + 570) / 18
        actionList.rowHeight = rowHeight
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
            
            print(action.name, action.duration)
            
            let alert = UIAlertController(title: "Edit Action", message:"", preferredStyle: .alert)
            
//            alert.addTextField { (name) in
//                name.placeholder = "Action Name"
//                name.text = action.name
//            }
            
            let updateAlertAction = UIAlertAction(title: "Update", style: .default) { (updateAction) in

                if(alert.textFields?[0].text! != ""){
                    let newAction = Action()
                    newAction.name = (alert.textFields?[0].text)!
                    newAction.duration = alert.textFields?[1].text != "" ? Int(alert.textFields?[1].text ?? "1")! : 1
                    
                    
                    self.updateSavedAction(oldAction: action, newAction: newAction)
                    tableView.reloadData();
                }

            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)

            alert.addAction(updateAlertAction)
            alert.addAction(cancel)
            
            alert.addTextField { (name) in
                name.placeholder = "Action Name"
                name.text = action.name
                self.validateUpdate(action: updateAlertAction,
                                    nameInput: name,
                                    initialValue: action.name,
                                    initialDurationValue: String(action.duration),
                                    alert: alert)
            }
            
            
            
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
    
    func updateSavedAction(oldAction: Action, newAction: Action) {
        do {
            try self.realm.write {
                oldAction.name = newAction.name
                oldAction.duration = newAction.duration
            }
        } catch {
            print("Error updating action, \(error)")
        }
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
            
            if(actionsList?.count ?? 0 < 1){
                let alert = UIAlertController(title: "No Actions Added Yet", message:"Add Actions Using the + Button", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
                return
            }
            
            currentAction = startAction
            currentActionDuration = startActionDuration
            //            currentAction = actionsList?[0].name ?? ""
//            currentActionDuration = actionsList?[0].duration ?? 10
            startTimer()
            timerRunning = true;
            startTimerButton.setTitle("Stop", for: .normal);
            currentActionLabel.text = "Get Set"
        } else {
            endTimer()
            timerRunning = !timerRunning;
            startTimerButton.setTitle("Start", for: .normal);
            currentActionLabel.text = "Press Start"
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
        
        print("validate num input updating action state")
    }
    
    // TODO: refactor into arrays and iterate through them
    // TODO: abstract so this works on both fields
    func validateUpdate(action: UIAlertAction, nameInput: UITextField,
                        initialValue: String, initialDurationValue: String, alert: UIAlertController) {
        
        var isUpdateValid = false  // preserves edit behavior while starting false on add
        action.isEnabled = isUpdateValid

        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nameInput, queue: OperationQueue.main) { (notification) in
            if let durationValue = alert.textFields?[1].text {
                isUpdateValid = self.isValidUpdate(initialVals: [initialValue, initialDurationValue],
                                               currentVals: [nameInput.text!, durationValue])
            } else {
                print("ERROR: duration value is missing")
            }
            
            print("validate update updating action state")
            action.isEnabled = isUpdateValid
        }

    }
    
    
    func isValidUpdate(initialVals: [String], currentVals: [String], numValIdx: Int = 1) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[0-9]*$", options: .caseInsensitive)
        
        var isUpdated = false
        for i in 0..<initialVals.count {
            isUpdated = isUpdated || currentVals[i] != initialVals[i]
        }
        
        var isValidNum = regex.firstMatch(in: currentVals[numValIdx], options: [], range: NSRange(location: 0, length: currentVals[numValIdx].count)) != nil
        isValidNum = isValidNum && currentVals[numValIdx].count > 0
        
        return isUpdated && isValidNum
    }
    
    
    func startTimer() {
        
        totalTime = currentActionDuration
        repCount = 0
        repLabel.text = "Reps: \(repCount)"
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        
        let minutes = totalTime / 60
        let seconds = totalTime % 60

        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
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
    
    func countdown() {
        readCountdown()
        updateCountdown()
    }
    
    func readCountdown() {
        if(totalTime == currentActionDuration){
            speakCount(phrase: currentAction)
            currentActionLabel.text = currentAction
            repLabel.text = "Reps: \(repCount)"
        } else if (totalTime != 0) {
            speakCount(phrase: String(totalTime))
        }
    }
    
    func updateCountdown() {
        if totalTime > 1 {
            totalTime -= 1
        } else {
            // Next Action
            if(currentActionIndex < ((actionsList?.count)! - 1)){
                currentActionIndex += 1
            } else {
                currentActionIndex = 0
                repCount += 1
            }
            currentAction = actionsList![currentActionIndex].name
            currentActionDuration = actionsList![currentActionIndex].duration
            totalTime = currentActionDuration
        }
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
        let iconScale = 0.0007*(self.view.frame.height + 570)
        let deleteIcon = resizeImage(image: UIImage(named: "delete-icon")!, scale: iconScale)
        deleteAction.image = deleteIcon//UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}

func resizeImage(image: UIImage, scale: CGFloat) -> UIImage {
    
    let newHeight = image.size.height * scale
    let newWidth = image.size.width * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}
