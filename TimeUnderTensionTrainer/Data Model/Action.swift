//
//  Data.swift
//  TimeUnderTensionTrainer
//
//  Created by Charles Griffin on 6/19/18.
//  Copyright © 2018 Charles Griffin. All rights reserved.
//

import Foundation
import RealmSwift

class Action: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var duration: Int = 0
    @objc dynamic var index: Int = 0
}
