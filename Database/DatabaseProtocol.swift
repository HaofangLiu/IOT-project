//
//  DatabaseProtocol.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 20/10/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import Foundation
enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case all
    case light
    case soundRecord
}

//set the database listener
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onLightStateChange(change: DatabaseChange, light:Light)
    func onSoundRecordListChange(change: DatabaseChange, soundRecords: [SoundRecord])
}

//define all database protocols
protocol DatabaseProtocol: AnyObject {
    
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addSoundRecord(soundDate: String,soundDB :String, soundLevel :String) -> SoundRecord
    func deleteSoundRecord(soundRecord: SoundRecord)
}
