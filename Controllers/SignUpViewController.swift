//
//  SignUpViewController.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 17/10/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBOutlet weak var nameTextfield: NewTextFileStyle!
    
    
    @IBOutlet weak var emailTextfield: NewTextFileStyle!
    
    
    @IBOutlet weak var password: NewTextFileStyle!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var activityIndicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
        
        activityIndicator =  UIActivityIndicatorView(style: .gray)
        activityIndicator.center = view.center
        activityIndicator.isHidden = true
        self.view.addSubview(activityIndicator)
        self.setupHideKeyboardOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterNotifications()
    }
    //same as before
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //same as before
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        scrollView.contentInset.bottom = 0
    }
    //show the keyboard
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    //show loading page
    func displayActivityIndicatorView() -> () {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    //remove loading page
    func hideActivityIndicatorView() -> () {
        if !self.activityIndicator.isHidden{
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
            }
        }
        
    }
    //setup all the button and textfield
    func setUpElements() {
        NewTextFileStyle.styleFilledButton(signUpButton)
    }
    //show the pop up window with error message
    func displayMessage(title: String, message: String) {
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func validateFields() -> String? {
        
        if nameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        // Check if the password is secure
        let cleanedPassword = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if NewTextFileStyle.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        return nil
    }
    
    //add the registered user
    @IBAction func signUpButton(_ sender: Any) {
        
        let errorMsg = validateFields()
        self.displayActivityIndicatorView()
        if errorMsg != nil{
            self.hideActivityIndicatorView()
            displayMessage(title: "check all fields again", message: errorMsg!)
        }
        else{
            let name = nameTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let passwordText = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: passwordText) { (result, err) in
                if err != nil {
                    self.hideActivityIndicatorView()
                    self.displayMessage(title: "Error to create uer", message: "dismiss")
                }
                else {
                    
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = name
                    changeRequest?.commitChanges(completion: { (error) in
                        if error == nil{
                            print("User display name saved!")
                            //save photo for more
                        }
                    })
                    let db = Firestore.firestore()
                    //db.collection("user").set
                    db.collection("users").document("\(result!.user.uid)").setData([
                        "name": name,
                        "uid": result!.user.uid,
                        "photoURL": ""
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                            self.loginSignedUpUser(email: email, passwordText: passwordText)
                        }
                    }
                    
                }
                
            }
        }
    }
    //after register then logged into app
    func loginSignedUpUser (email:String, passwordText:String){
        Auth.auth().signIn(withEmail: email, password: passwordText) { (result, error) in
            
            if error != nil {
                // Couldn't sign in
                self.hideActivityIndicatorView()
                self.displayMessage(title: "email or password is not correct", message: "try agin")
            }
            else {
                let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? MainTabController
                self.hideActivityIndicatorView()
                self.present(tabViewController!,animated: true,completion: nil)
            }
        }
    }
    
}
