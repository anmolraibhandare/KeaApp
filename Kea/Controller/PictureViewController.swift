//
//  PictureViewController.swift
//  Kea
//
//  Created by Anmol Raibhandare on 9/3/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController {

    // MARK: IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Variables
    
    var breeds: [String] = []
    var dogImage : UIImage!
    var user: User!
    var query: String!
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.alpha = 0
        DogAPI.requestBreedsList(completionHandler: handleBreedsListResponse(breeds:error:))
    }

    func handleBreedsListResponse(breeds: [String], error: Error?){
        self.breeds = breeds
        DispatchQueue.main.async {
            self.pickerView.reloadAllComponents()
            
        }
    }

    func handleRandomImageResponse(imageData: DogImage?, error: Error?){
        guard let imageURL = URL(string: imageData?.message ?? "") else {
            return
        }
        DogAPI.requestImageFile(url: imageURL, completionHandler: self.handleImageFileResponse(image:error:))
    }

    func handleImageFileResponse(image: UIImage?, error: Error?){
        DispatchQueue.main.async {
            self.imageView.image = image
            self.dogImage = image
            self.activityIndicator.alpha = 0
            self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: Add Pet Button Tapped
    
    @IBAction func addPetButton(_ sender: Any) {
        // Transition to HomeViewController with Pet
        let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        homeViewController?.dogImageFromUser = self.dogImage
        homeViewController?.user = self.user
        homeViewController?.queryUser = self.query
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()

    }
}

// MARK: Picker View Delegates
extension PictureViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return breeds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return breeds[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
        self.activityIndicator.alpha = 1
        self.activityIndicator.startAnimating()
        DogAPI.requestRandomImage(breed: breeds[row], completionHandler: handleRandomImageResponse(imageData:error:))
    }
    
}
