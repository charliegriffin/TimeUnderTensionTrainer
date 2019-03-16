//
//  CustomCell.swift
//  TimeUnderTensionTrainer
//
//  Created by Charles Griffin on 1/20/19.
//  Copyright © 2019 Charles Griffin. All rights reserved.
//

import Foundation
import UIKit
import SwipeCellKit

class CustomCell: SwipeTableViewCell {
    var actionName : String?
    var duration : String?
    
    var actionLabel : LeftPaddingLabel = {
        let label = LeftPaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    var durationLabel : RightPaddingLabel = {
        let label = RightPaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(actionLabel)
        self.addSubview(durationLabel)

        actionLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        actionLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        actionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        actionLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
        
        durationLabel.leftAnchor.constraint(equalTo: self.actionLabel.rightAnchor).isActive = true
        durationLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        durationLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        durationLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let actionName = actionName {
            actionLabel.text = actionName
        }
        
        if let duration = duration {
            durationLabel.text = duration
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@IBDesignable class LeftPaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    @IBInspectable var leftInset: CGFloat = 20
    @IBInspectable var rightInset: CGFloat = 0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}

@IBDesignable class RightPaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    @IBInspectable var leftInset: CGFloat = 0
    @IBInspectable var rightInset: CGFloat = 10
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}
