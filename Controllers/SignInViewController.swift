//
//  SignInViewController.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 17/10/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailTextField: NewTextFileStyle!
    
    
    @IBOutlet weak var password: NewTextFileStyle!
    
    
    @IBOutlet weak var signInButton: UIButton!
    
    
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
    
    
    
    //same as before
    func displayActivityIndicatorView() -> () {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    //same as before
    func hideActivityIndicatorView() -> () {
        if !self.activityIndicator.isHidden{
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterNotifications()
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        scrollView.contentInset.bottom = 0
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    

    func setUpElements() {
        NewTextFileStyle.styleFilledButton(signInButton)
        NewTextFileStyle.styleFilledButton(signUpButton)
    }
    
    func displayMessage(title: String, message: String) {
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    //using auth to login the application
    @IBAction func signInButtonTapped(_ sender: Any) {
        
        self.displayActivityIndicatorView()
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordT = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: passwordT) { (result, error) in
            
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

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
