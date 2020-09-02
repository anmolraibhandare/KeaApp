//
//  HomeViewController.swift
//  Kea
//
//  Created by Anmol Raibhandare on 8/31/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseFirestore

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    
    var emailFromLogin: String!
    var passwordFromLogin: String!
    var userData: UserData!
    
    private var fetchResultController: NSFetchedResultsController<Pet>!
    private var query = ""
    let appDelegate: AppDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
        }()

    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let formatter = DateFormatter()
    
    private var isFiltered = false
    private var filtered = [String]()
    private var selected:IndexPath!
    private var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        formatter.dateFormat = "d MM yyy"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    private func refresh() {
        
        let request = Pet.fetchRequest() as NSFetchRequest<Pet>
        if query.isEmpty {
            request.predicate = NSPredicate(format: "owner = %@", user)
        } else {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ AND owner = %@", query, user)
        }
        let sort = NSSortDescriptor(key: #keyPath(Pet.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors = [sort]
        do{
            fetchResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            try fetchResultController.performFetch()
        } catch let error as NSError {
            print("Could not Fetch data. \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func longPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .ended {
            return
        }
        let point = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: point){
            let pet = fetchResultController.object(at: indexPath)
            context.delete(pet)
            appDelegate.saveContext()
            refresh()
        }
    }
    
    @IBAction func addPet(_ sender: Any) {
        let data = PetData()
        let pet = Pet(entity: Pet.entity(), insertInto: context)
        pet.name = data.name
        pet.kind = data.kind
//        pet.dob = data.dob
        pet.owner = user
        appDelegate.saveContext()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let pets = fetchResultController.fetchedObjects else {
            return 0
        }
        return pets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PetCell", for: indexPath) as! PetCell
        let pet = fetchResultController.object(at: indexPath)
        cell.nameLabel.text = pet.name
        cell.animalLabel.text = pet.kind
        if let dob = pet.dob as Date? {
            cell.dobLabel.text = formatter.string(from: dob)
        } else {
            cell.dobLabel.text = "Unknown"
        }
        if let data = pet.picture as Data? {
            cell.pictureImageView.image = UIImage(data: data)
        } else {
            cell.pictureImageView.image = UIImage(named: "pet")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath
        self.navigationController?.present(picker, animated: true, completion: nil)
    }
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let pet = fetchResultController.object(at: selected)
        let info = convertInfoKeyDict(info)
        let image = info[convertInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        pet.picture = image.pngData() as Data?
        appDelegate.saveContext()
        tableView?.reloadRows(at: [selected], with: UITableView.RowAnimation.automatic)
        picker.dismiss(animated: true, completion: nil)
    }
}

fileprivate func convertInfoKeyDict(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

fileprivate func convertInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        let index = indexPath ?? (newIndexPath ?? nil)
        guard let cellIndex = index else {
            return
        }
        switch type {
        case .insert:
            tableView.insertRows(at: [cellIndex], with: UITableView.RowAnimation.automatic)
        case .delete:
            tableView.deleteRows(at: [cellIndex], with: UITableView.RowAnimation.automatic)
        default:
            break
        }
    }
}
