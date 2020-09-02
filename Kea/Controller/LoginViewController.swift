//
//  LoginViewController.swift
//  Kea
//
//  Created by Anmol Raibhandare on 8/31/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class LoginViewController: UIViewController {

    // MARK: IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var userId: String!
    
    private var usersCollectionRef: CollectionReference!
    
    var userData: UserData!
    var user: User!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        usersCollectionRef = Firestore.firestore().collection("users")
    }
    
    func setUpElements() {
        
        // Hide Error Label
        errorLabel.alpha = 0
        
        // Style UI Elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    func validateFields() -> String? {
        
        // Check all fields are non-empty
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields"
        }
        return nil
    }

    @IBAction func loginTapped(_ sender: Any) {
        
        // Validate Text fields
        let error = validateFields()
        
        if error != nil {
            // Show error message
            showError(error!)
        } else {
            
            // Create cleaned versions of the data
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
        
            // SignIn the user
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
               // Check for error
                if error != nil {
                    self.errorLabel.text = error!.localizedDescription
//                    self.showError("Error logining in")
                } else {
                    // User signed in successfully
                    self.userId = result!.user.uid
                    
                    // Transition to home screen
                    let userViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.userViewController) as? UserViewController
                    userViewController?.userIDfromlogin = self.userId
                    self.view.window?.rootViewController = userViewController
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
    }

    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
}
