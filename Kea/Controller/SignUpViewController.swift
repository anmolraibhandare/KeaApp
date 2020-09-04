//
//  SignUpViewController.swift
//  Kea
//
//  Created by Anmol Raibhandare on 8/31/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController {

    // MARK: IBOutlets
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Variables
    
    var user: UserData!
    private var fetchResultController: NSFetchedResultsController<User>!
    private var query = ""
    let appDelegate: AppDelegate = { return UIApplication.shared.delegate as! AppDelegate }()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    private var isFiltered = false
    private var filtered = [String]()
    private var selected:IndexPath!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpElements() {
        
        // Hide Error Label 
        errorLabel.alpha = 0
        activityIndicator.alpha = 0
        
        // Style UI Elements
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
    }
    
    // Check the fields and validate data. If correct, return nil otherwise return nil
    func validateFields() -> String? {
        
        // Check all fields are non-empty
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields"
        }
        
        // Check the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            //Password isn't secure enough
            return "Please make sure the password is at least 8 characters, contains a special character and a number"
        }
        return nil
    }
 

    @IBAction func signUpTapped(_ sender: Any) {
        
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
        
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            // Show error message
            showError(error!)
        } else {
            
            // Create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                // Check for error
                if error != nil {
                    self.errorLabel.text = error!.localizedDescription
                } else {
                    // User created successfully
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["firstname" : firstName, "lastname" : lastName, "uid" : result!.user.uid, "email" : email, "password" : password]) { (error) in
                        
                        if error != nil {
                            self.errorLabel.text = error!.localizedDescription
//                            self.showError("Error saving user data")
                        }

                    }
                    let data = UserData(firstname: firstName, lastname: lastName, uid: result!.user.uid)
                    let user = User(entity: User.entity(), insertInto: self.context)
                    user.firstname = data.firstname
                    user.lastname = data.lastname
                    user.userid = data.userid
                    self.appDelegate.saveContext()
                    self.refresh()
                    
                    // Transition to home screen
                    let userViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.userViewController) as? UserViewController
                    userViewController?.userIDfromlogin = user.userid
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
    
    // MARK:- Navigation

    
    private func refresh() {
        let request = User.fetchRequest() as NSFetchRequest<User>
        if !query.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        }
        let sort = NSSortDescriptor(key: #keyPath(User.firstname), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors = [sort]
        do{
            fetchResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchResultController.performFetch()
        } catch let error as NSError {
            print("Could not Fetch data. \(error), \(error.userInfo)")
        }
    }

}
