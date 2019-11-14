//
//  EditProfileViewController.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 29/10/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var photoSection: GetSoundView!
    @IBOutlet weak var nameSection: GetSoundView!
    @IBOutlet weak var myHeadPortrait: UIImageView!
    
    
    
    @IBOutlet weak var userNameTextLabel: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    var activityIndicator : UIActivityIndicatorView!
    
    var imagePicker:UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator =  UIActivityIndicatorView(style: .gray)
        activityIndicator.center = view.center
        activityIndicator.isHidden = true
        self.view.addSubview(activityIndicator)

        myHeadPortrait.makeRounded()
        // Do any additional setup after loading the view.
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        myHeadPortrait.isUserInteractionEnabled = true
        myHeadPortrait.addGestureRecognizer(imageTap)
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        let user = Auth.auth().currentUser
        userNameTextLabel.placeholder = user?.displayName
        if user?.photoURL != nil{
        ImageService.getImage(withURL: (user?.photoURL)!) { image in
            self.myHeadPortrait.image = image
            }
        }
        setUpElements()
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
    
    //register for the keyboard disappear
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //remove the observe
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        scrollView.contentInset.bottom = 0
    }
    
    //keyboard will show when click on the text field
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    func displayActivityIndicatorView() -> () {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    //hide the loading function
    func hideActivityIndicatorView() -> () {
        if !self.activityIndicator.isHidden{
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
            }
        }
        
    }
    
    func setUpElements() {
        NewTextFileStyle.styleFilledButton(doneButton)
    }
    
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    

    @IBAction func editHeadButtonTapped(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func displayMessage(title: String, message: String) {
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func finishEditButtonTapped(_ sender: Any) {
        
        let userName = userNameTextLabel.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if userName == ""{
            displayMessage(title: "check all fields again", message: "cannot edit with empty use name")
        }
        else{
        self.displayActivityIndicatorView()
        guard let image = myHeadPortrait.image else { return }
        self.uploadProfileImage(image) { (url) in
            if url != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.userNameTextLabel.text
                changeRequest?.photoURL = url
                
                changeRequest?.commitChanges(completion: { (error) in
                    if error == nil{
                        print("save successful")
                        self.saveProfile(username: self.userNameTextLabel.text!, profileImageURL: url!, completion: { (success) in
                            if success{
                                let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? MainTabController
                                self.hideActivityIndicatorView()
                                self.present(tabViewController!,animated: true,completion: nil)
                            }
                        })
                    }
                })
            }
            }
        }
    }
    
        func saveProfile(username:String, profileImageURL:URL, completion: @escaping ((_ success:Bool)->())) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            //db.collection("user").set
            db.collection("users").document("\(uid)").setData([
                "name": username,
                "uid": uid,
                "photoURL": profileImageURL.absoluteString
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    completion(err == nil)
                }
            }
        }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")

        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }


        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"

        storageRef.putData(imageData, metadata: metaData, completion: { (metaData, error) in
            if error == nil, metaData != nil {
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    completion(downloadURL)
                }
                completion(nil)
            } else {
                completion(nil)
            }
        })
    }
    
    
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.myHeadPortrait.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
