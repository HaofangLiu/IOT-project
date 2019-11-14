//
//  AddSoundViewController.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 3/11/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class AddSoundViewController: UIViewController {
    
    
    @IBOutlet weak var soundMeterLabel: UILabel!
    
    
    @IBOutlet weak var summaryLabel: UILabel!
    
    
    @IBOutlet weak var PeopleRecLabel: UILabel!
    
    
    @IBOutlet weak var environRecLabel: UILabel!
    
    
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var tipsRecLabel: UILabel!
    
    var soundNumber: String?
    
    var soundLevel: String?
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        // Do any additional setup after loading the view.
        setUpElements()
        
    }
    func setUpElements() {
        NewTextFileStyle.styleFilledButton(gotItButton)
    }
    //read the data and provide some feedback based on the sound db number
    func getTempAndPre(){
        var soundNumberString:String?
        var soundNumberInt = 0
        let soundRef = Firestore.firestore().collection("soundUpdate").document("sound")
        soundRef.getDocument(completion: { (document, error) in
            if let document = document, document.exists{
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                soundNumberString = (document.data()!["db"] as? String)!
                print("Document data: \(dataDescription)")
//                self.soundMeterLabel.text = soundNumberString
                soundNumberInt = Int(soundNumberString!)!
                switch soundNumberInt{
                case 0...50:
                    self.soundMeterLabel.text = "Low Level - \(soundNumberString ?? "20") dB"
                    self.soundNumber = soundNumberString!
                    self.soundLevel = "Low Level"
                case 50...80:
                    self.soundMeterLabel.text = "Medium Level - \(soundNumberString ?? "60") dB"
                    self.soundNumber = soundNumberString!
                    self.soundLevel = "Medium Level"
                case 80...120:
                    self.soundMeterLabel.text = "High level - \(soundNumberString ?? "90") dB"
                    self.soundNumber = soundNumberString!
                    self.soundLevel = "High Level"
                default:
                    print("null value of sound")
                }
                self.getTheTipsLabel()
            }
        })
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        getTempAndPre()
        
    }
    //the corresponding label
    func getTheTipsLabel(){
        switch soundLevel {
        case "Low Level":
            summaryLabel.text = "The environment is now perfect for a lovely rest."
            PeopleRecLabel.text = "Feel comfortable to have your rest no matter in the bed or on the sofa!"
            environRecLabel.text = "Keep the window and curtain closed will protect you from potential noise."
            tipsRecLabel.text = "Did you know quite place arouse creativity inside of people and permits reflection!"
        case "Medium Level":
            summaryLabel.text = "The environment is not quite enough for rest,to improve the rest quality, you may:"
            PeopleRecLabel.text = "Wear a nice earphone or headphone to isolate the noise."
            environRecLabel.text = "Close noisy machine in your room such as air-conditioner or cleaner."
            tipsRecLabel.text = "Did you know: Stay in a quiet place helps to heal insomnia and anxiety!"
        case "High Level":
            summaryLabel.text = "The environment is currently very noisy. If you need some rest, you may:"
            PeopleRecLabel.text = "Use earplugs or in-ear phones to create your own space."
            environRecLabel.text = "KClose or reinforce the windows to keep out outdoor noise."
            tipsRecLabel.text = "Did you know: Stay in a quiet place regularly helps to lower blood pressure and prevent heart attack!"
        default:
            print("null")
        }
    }
    
    //store the sound with label to user record
    @IBAction func addSoundRecordButtonTapped(_ sender: Any) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-YYYY,hh:mm:ss"
        let dateSting = formatter.string(from: Date())
        let DB = soundNumber!
        let level = soundLevel!
        let _ = databaseController!.addSoundRecord(soundDate: dateSting, soundDB: DB, soundLevel: level)
        navigationController?.popViewController(animated: true)
        let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? MainTabController
        self.present(tabViewController!,animated: true,completion: nil)
        return
        
    }
    

}
