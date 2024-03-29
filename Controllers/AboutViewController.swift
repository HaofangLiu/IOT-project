//
//  AboutViewController.swift
//  5140AssignmentStarter
//
//  Created by XinzhuoYu on 10/11/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var referenceButton: UIButton!
    @IBOutlet weak var whatsNewButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
    }
    func setUpElements() {
        NewTextFileStyle.styleFilledButton(whatsNewButton)
        NewTextFileStyle.styleFilledButton(referenceButton)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
