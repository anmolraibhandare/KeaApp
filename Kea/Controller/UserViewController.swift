//
//  UserViewController.swift
//  Kea
//
//  Created by Anmol Raibhandare on 9/1/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

class UserViewController: UIViewController {
    
    var userId = "MEahwYgX0sPmTBMkyHNNtQEt9gJ2" // To be set from signup page
    var user: UserData!
    private var fetchResultController: NSFetchedResultsController<User>!
    private var query = ""
    let appDelegate: AppDelegate = { return UIApplication.shared.delegate as! AppDelegate }()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    private var isFiltered = false
    private var filtered = [String]()
    private var selected:IndexPath!

    private var usersCollectionRef: CollectionReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersCollectionRef = Firestore.firestore().collection("users")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        usersCollectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                debugPrint("Error fetching docs: \(error)")
            } else {
                guard let snap = snapshot else {
                    return
                }
                for document in snap.documents {
                    let data = document.data()
                    let firstname = data["firstname"] as? String ?? "Anonymous"
                    let lastname = data["lastname"] as? String ?? "Anonymous"
                    let userID = data["uid"] as? String ?? ""
                    print("first name \(firstname), lastname \(lastname)")
                    
                    if userID == self.userId {
                        self.user = UserData(firstname: firstname, lastname: lastname)
                        print("Current User First Name:  \(self.user.firstname) Last Name: \(self.user.lastname)")
                    }
                }
                self.appDelegate.saveContext()
                self.refresh()
            }
        }
    }
    
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


//        firstname.text = user.firstname
//          lastname.text = user.lastname
