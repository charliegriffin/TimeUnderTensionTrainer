//
//  CustomCell.swift
//  TimeUnderTensionTrainer
//
//  Created by Charles Griffin on 1/20/19.
//  Copyright © 2019 Charles Griffin. All rights reserved.
//

import Foundation
import UIKit

class CustomCell: UITableViewCell {
    var actionName : String?
    var duration : String?
    
    var actionView : UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 18.0)
        textView.isUserInteractionEnabled = false
        // TODO: left align with divider
        return textView
    }()
    
    var durationView : UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .right
        textView.font = UIFont.systemFont(ofSize: 18.0)
        textView.isUserInteractionEnabled = false
        // TODO: add right padding
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(actionView)
        self.addSubview(durationView)

        actionView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        actionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        actionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        actionView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
        
        durationView.leftAnchor.constraint(equalTo: self.actionView.rightAnchor).isActive = true
        durationView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        durationView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        durationView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let actionName = actionName {
            actionView.text = actionName
        }
        
        if let duration = duration {
            durationView.text = duration
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
