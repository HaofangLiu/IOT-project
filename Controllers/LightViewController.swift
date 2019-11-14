//
//  LightViewController.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 1/11/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import Firebase

class LightViewController: UIViewController {
    var listenerType = ListenerType.light
    
    var timer = Timer()
    @IBOutlet weak var light2Switch: UISwitch!
    
    
    @IBOutlet weak var light1StateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        light2Switch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        showStateLabel()
    }
    
    
    func showStateLabel(){
//        let stateIndicator = databaseController?.getLightState()
        //print(databaseController?.getLightState())'
        var state = 10
        let lightRefState = Firestore.firestore().collection("entryLight").document("light1")
        lightRefState.getDocument(completion: { (document, error) in
            if let document = document, document.exists{
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                state = document.data()!["state"] as! Int
                print("Document data: \(dataDescription)")
                //print(state)
                if state == 0{
                    self.light1StateLabel.text = "OFF"
                }
                else if state == 1{
                    self.light1StateLabel.text = "ON"
                }
            }
        })
        
    }
    
    func onLightStateChange(change: DatabaseChange, light: Light) {

        showStateLabel()
    }
    
    @objc func stateChanged(switchState: UISwitch) {
        let db = Firestore.firestore()
        if switchState.isOn {
            //light is on
            db.collection("bedroomLight").document("light2").setData([
                "state": "1"
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("bedroom light is on")
                }
            }
        } else {
            //lihght is off
            db.collection("bedroomLight").document("light2").setData([
                "state": "0"
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("bedroom light is off!")
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showStateLabel()
        scheduledTimerWithTimeInterval()
        //databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }

}
