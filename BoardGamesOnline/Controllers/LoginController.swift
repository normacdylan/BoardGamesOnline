//
//  LoginController.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-28.
//  Copyright © 2018 August Posner. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameEdit: UITextField!
    @IBOutlet weak var emailEdit: UITextField!
    @IBOutlet weak var passwordEdit: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameEdit.delegate = self
        self.emailEdit.delegate = self
        self.passwordEdit.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "loginToLobbySegue", sender: self)
        }
        if let email = UserDefaults.standard.object(forKey: "email") {
            segmentControl.selectedSegmentIndex = 1
            button.titleLabel?.text = "Log In"
            usernameEdit.isHidden = true
            emailEdit.text = (email as! String)
        }
        if let password = UserDefaults.standard.object(forKey: "password") {
            passwordEdit.text = (password as! String)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == usernameEdit {
            emailEdit.becomeFirstResponder()
        } else if textField == emailEdit {
            passwordEdit.becomeFirstResponder()
        }
        return true
    }
    
    @IBAction func pressedButton(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0 {
            handleSignUp()
        } else {
            handleLogin()
        }
    }
    
    func saveLogIn(email: String, password: String) {
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(password, forKey: "password")
    }
    
    @IBAction func pressedSegment(_ sender: Any) {
        button.titleLabel?.text = segmentControl.selectedSegmentIndex == 0 ? "Register" : "Log In"
        usernameEdit.isHidden = segmentControl.selectedSegmentIndex == 1
        
    }
    
    func handleSignUp() {
        guard let username = usernameEdit.text else {return}
        guard let email = emailEdit.text else {return}
        guard let password = passwordEdit.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
                print("User created")
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges() { error in
                    if error == nil {
                        print("Username added")
                    } else {
                        let alert = UIAlertController(title: "Could not choose username", message: error!.localizedDescription , preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
                
                self.saveLogIn(email: email, password: password)
                self.performSegue(withIdentifier: "loginToLobbySegue", sender: self)
                
            } else {
                print("Error creating user: \(error!.localizedDescription)")
                let alert = UIAlertController(title: "Could not register", message: error!.localizedDescription , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    func handleLogin() {
        guard let email = emailEdit.text else {return}
        guard let password = passwordEdit.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
                print("Logged in")
                self.saveLogIn(email: email, password: password)
                self.performSegue(withIdentifier: "loginToLobbySegue", sender: self)
            } else {
                print("Error when logging in: \(error!.localizedDescription)")
                let alert = UIAlertController(title: "Could not log in", message: error!.localizedDescription , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
}
