//
//  SoundRecord.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 3/11/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import Foundation
class SoundRecord: NSObject {
    public var soundId: String
    public var soundDate: String
    public var soundDB: String
    public var soundLevel: String
    
    override init() {
        self.soundId = ""
        self.soundDate = ""
        self.soundDB = ""
        self.soundLevel = ""
    }
    
}
