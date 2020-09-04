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


    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeter: Double = 10000
    var previousLocation: CLLocation?
    var directionsArray: [MKDirections] = []
    
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
    var query: String!

    private var usersCollectionRef: CollectionReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressLabel.text = "Location"
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
                pvc.queryForBack = self.query
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
            startTrackingUserLocation()
            
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
    
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            // Inform user on not having a current location
            return
        }
        
        // Create request
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { [unowned self] (response, error) in
            // Handle error
            guard let response = response else {
                // Show alert
                return
            }
            
            // Response is array of routes. Because we requested alternate routes
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        
        // Request needs a starting and ending location
        // Destination is center of map view
        // Starting is the user location
        // Pass in the destination coordinate to destination location
        let destinationCoordinate = getCenterLocation(for: mapView).coordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        // Make request
        let request = MKDirections.Request()
        
        // Start location, destination location
        // Transportation can be walk
        // Alternate routes is true
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {
            $0.cancel()
        }
    }
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        // Get directions
        getDirections()
    }
    
    
}

// Table View Delegates
extension UserViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let sections = fetchResultController.sections, let objs =
            sections[section].objects else {
                return 0
        }
        return 1
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
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
//        mapView.setRegion(region, animated: true)
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthoriztion()
    }
    
}

extension UserViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else {
            return
        }
        
        guard center.distance(from: previousLocation) > 50 else {
            return
        }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarkers, error) in
            guard let self = self else {
                return
            }
            
            if let _ = error {
                // Show alert
                return
            }
            
            guard let placemark = placemarkers?.first else {
                // Show alert
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        
        return render
    }
    
    
}
