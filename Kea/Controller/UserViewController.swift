//
//  UserViewController.swift
//  Kea
//
//  Created by Anmol Raibhandare on 9/1/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//
//
import Foundation
import UIKit
import CoreData
import MapKit
import CoreLocation
import Firebase
import FirebaseFirestore

class UserViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeter: Double = 10000
    
    var userIDfromlogin: String!
    var userData: UserData!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchResultController: NSFetchedResultsController<User>!
    private var filtered = User()
    private var isFiltered = false
    private var selected:IndexPath!
    private var picker = UIImagePickerController()
    private var queryFirstName = ""
    private var queryLastName = ""
    private var query = ""

    private var usersCollectionRef: CollectionReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        usersCollectionRef = Firestore.firestore().collection("users")
        picker.delegate = self
        checkLocationServices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        self.query = self.userIDfromlogin
        
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

                    if userID == self.userIDfromlogin {
                        self.userData = UserData(firstname: firstname, lastname: lastname, uid: self.userIDfromlogin)
                        print("User Data First Name:  \(self.userData.firstname ) Last Name: \(self.userData.lastname )")
                        let user = User(entity: User.entity(), insertInto: self.context)
                        user.firstname = self.userData.firstname
                        user.lastname = self.userData.lastname
                        user.userid = self.userData.userid
                        self.queryFirstName = self.userData.firstname
                        self.queryLastName = self.userData.lastname
                        print("NSObject First Name:  \(user.firstname ?? "f not found") Last Name: \(user.lastname ?? "l not found")")
                        print("Queryyy   \(self.queryFirstName) \(self.queryLastName)")
    
                    }
                }
            }
        }
        refresh()
        showEditButton()
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeVC" {
            if let index = sender as? IndexPath {
                let pvc = segue.destination as! HomeViewController
                let user = fetchResultController.object(at: index)
                pvc.user = user
            }
        }
    }
    
        private func showEditButton() {
            guard let objs = fetchResultController.fetchedObjects else {
                return
            }
            if objs.count > 0 {
                navigationItem.leftBarButtonItem = editButtonItem
            }
        }
        
        private func refresh(){
            let request = User.fetchRequest() as NSFetchRequest<User>
            if !query.isEmpty {
                request.predicate = NSPredicate(format: "userid == %@", query)
            }
            let sort = NSSortDescriptor(key: #keyPath(User.userid), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            request.sortDescriptors = [sort]
            do {
                fetchResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                try fetchResultController.performFetch()
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        // Check if the user's iphone supports location services
        if CLLocationManager.locationServicesEnabled() {
            
            // Setup our location manager
            setupLocationManager()
            // Check Location Authorization
            checkLocationAuthoriztion()
            
        } else {
            
            // Show alert to let users know that the location services needs to be turned on
            
        }
    }
    
    func checkLocationAuthoriztion() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            // Locate the user's map locations
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing users how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        }
    }
    
    
    
}

// Table View Delegates
extension UserViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let sections = fetchResultController.sections, let objs =
            sections[section].objects else {
                return 0
        }
        return objs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let friend = fetchResultController.object(at: indexPath)
        cell.firstname.text = friend.firstname
        cell.lastname.text = friend.lastname!
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            selected = indexPath
            self.navigationController?.present(picker, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "HomeVC", sender: indexPath)
        }
    }
}
    // Image Picker Delegates
    extension UserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // Local variable inserted by Swift 4.2 migrator.
    let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

            let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
            let user = fetchResultController.object(at: selected)
            appDelegate.saveContext()
            tableView?.reloadRows(at: [selected], with: UITableView.RowAnimation.automatic)
            picker.dismiss(animated: true, completion: nil)
        }
    }



    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }

    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }


extension UserViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthoriztion()
    }
    
}
