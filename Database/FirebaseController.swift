//
//  FirebaseController.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 20/10/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
class FirebaseController: NSObject, DatabaseProtocol {
    
    
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    
    //Ref
    var lightRef : CollectionReference?
    var soundRef : CollectionReference?
    var lightState: Light
    //var soundRecord: SoundRecord
    var soundRecordList: [SoundRecord]
    //var userCurrent : User
    
    override init() {
//        // To use Firebase in our application we first must run the FirebaseApp configure method
        //FirebaseApp.configure()
        // We call auth and firestore to get access to these frameworks
        authController = Auth.auth()
        database = Firestore.firestore()
        
        //userCurrent = User()
        lightState = Light()
        //soundRecord = SoundRecord()
        soundRecordList = [SoundRecord]()
        super.init()
        
        // This will START THE PROCESS of signing in with an anonymous account
        // The closure will not execute until its recieved a message back which can be any time later
//        authController.signInAnonymously() { (authResult, error) in
//            guard authResult != nil else {
//                fatalError("Firebase authentication failed")
//            }
//            // Once we have authenticated we can attach our listeners to the firebase firestore
//            //self.setUpListeners()
//        }
        
        if authController.currentUser != nil{
            self.setUpListeners()
        }
        else{
            fatalError("Firebase authentication failed")
        }
        
    }
    
    func setUpListeners(){

        let currentLoggedUser  = Auth.auth().currentUser
        soundRef = database.collection("users").document("\(currentLoggedUser!.uid)").collection("data")
        print("\(currentLoggedUser!.uid)")
        soundRef?.addSnapshotListener { querySnapshot,error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching sound data: \(error!)")
                return
            }
            self.parseSoundSnapshot(snapshot: querySnapshot!)
        }
        
    }
    
    func parseSoundSnapshot(snapshot: QuerySnapshot)
    {
        snapshot.documentChanges.forEach { change in
            
            let documentRef = change.document.documentID
            let soundDate = change.document.data()["soundDate"] as! String
            let soundDB = change.document.data()["soundDB"] as! String
            let soundLevel = change.document.data()["soundLevel"] as! String
            print(documentRef)
            
            if change.type == .added {
                print("New Record: \(change.document.data())")
                let recordNew = SoundRecord()
                recordNew.soundDate = soundDate
                recordNew.soundDB = soundDB
                recordNew.soundLevel = soundLevel
                recordNew.soundId = documentRef
                
                soundRecordList.append(recordNew)
            }
            
            if change.type == .removed {
                print("Removed Record: \(change.document.data())")
                if let index = getRecordIndexByID(reference: documentRef) {
                    soundRecordList.remove(at: index)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.soundRecord || listener.listenerType == ListenerType.all {
                listener.onSoundRecordListChange(change: .update, soundRecords: soundRecordList)
            }
        }
    }
    
    func getRecordIndexByID(reference: String) -> Int? {
        for record in soundRecordList {
            if(record.soundId == reference) {
                return soundRecordList.firstIndex(of: record)
            }
        }
        
        return nil
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == ListenerType.soundRecord || listener.listenerType == ListenerType.all {
                        listener.onSoundRecordListChange(change: .update, soundRecords: soundRecordList)
                    }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
        
    }
    
    func deleteSoundRecord(soundRecord: SoundRecord)
    {
       
        soundRef?.document(soundRecord.soundId).delete()
    }
    
    func addSoundRecord(soundDate: String, soundDB: String, soundLevel: String) -> SoundRecord {
        let soundRecord = SoundRecord()
        let addDocSound = soundRef?.addDocument(data: ["soundDB": soundDB,"soundDate" : soundDate,"soundLevel": soundLevel])
        soundRecord.soundDate = soundDate
        soundRecord.soundLevel = soundLevel
        soundRecord.soundDB = soundDB
        soundRecord.soundId = addDocSound!.documentID
        return soundRecord
    }
    
}
