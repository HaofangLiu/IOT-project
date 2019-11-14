//
//  HomeViewController.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 17/10/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class HomeViewController: UIViewController,CLLocationManagerDelegate {
    
    
    
    @IBOutlet weak var nameTextFIeld: UILabel!
    
    @IBOutlet weak var PlaceLabel: UILabel!
    
    @IBOutlet weak var DateAndTimeLabel: UILabel!
    
    
    
    @IBOutlet weak var degreeLabel: UILabel!
    
    
    @IBOutlet weak var pressureLabel: UILabel!
    
    
    var handle: AuthStateDidChangeListenerHandle?
    
    weak var databaseController: DatabaseProtocol?
    
    let locationManager = CLLocationManager()
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        let user = Auth.auth().currentUser
        nameTextFIeld.text = user?.displayName
        // Do any additional setup after loading the view.
        //configUserName()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        getCurrentTime()
        getTempAndPre()
    }
    //read data from firebase
    func getTempAndPre(){
        var temp: String?
        var pressure: String?
        let tempRef = Firestore.firestore().collection("weatherUpdate").document("weather1")
        tempRef.getDocument(completion: { (document, error) in
            if let document = document, document.exists{
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                temp = document.data()!["temp"] as? String
                pressure = document.data()!["pressure"] as? String
                print("Document data: \(dataDescription)")
                self.degreeLabel.text = "\(temp ?? "23")°"
                self.pressureLabel.text = "\(pressure ?? "0.242")kPA"
                }
        })
    }
    //get the current time
    func getCurrentTime() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.currentTime) , userInfo: nil, repeats: true)
    }
    //show in some format
    @objc func currentTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-YYYY,hh:mm:ss"
        DateAndTimeLabel.text = formatter.string(from: Date())
    }
    //using the location service
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    //fetch the current city and country
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = manager.location else { return }
        fetchCityAndCountry(from: location) { city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            print(city + ", " + country)
            self.PlaceLabel.text = "\(city),\(country)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
//
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

}
