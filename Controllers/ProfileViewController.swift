//
//  ProfileViewController.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 28/10/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import Firebase


class ProfileViewController: UIViewController {

    
    
    @IBOutlet weak var myHeadPortrait: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myHeadPortrait.layer.borderWidth = 1
        myHeadPortrait.layer.masksToBounds = false
        myHeadPortrait.layer.borderColor = UIColor.white.cgColor
        myHeadPortrait.layer.cornerRadius = myHeadPortrait.frame.width/2
        myHeadPortrait.clipsToBounds = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        let user = Auth.auth().currentUser
        userNameLabel.text = user?.displayName
        if user?.photoURL != nil{
            ImageService.getImage(withURL: (user?.photoURL)!) { image in
                self.myHeadPortrait.image = image
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        
        do
        {
            try Auth.auth().signOut()
            //_ = FirebaseController()
            let lol = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.SignUpViewController)
            self.present(lol!,animated: true,completion: nil)
        }
        catch let error as NSError
        {
            print (error.localizedDescription)
        }

        
    }
    
}
