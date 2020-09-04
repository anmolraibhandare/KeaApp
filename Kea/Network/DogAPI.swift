//
//  DogAPI.swift
//  Kea
//
//  Created by Anmol Raibhandare on 9/3/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//

import Foundation
import UIKit

class DogAPI{
        enum Endpoint{
            
            // Endpoints for DogAPI
            case randomImageFromAllDogsCollection
            case randomImageForBreed (String)
            case listAllBreeds
        
            var url: URL{
                return URL(string: self.stringValue)!
            }
            var stringValue: String{
                switch self {
                case .randomImageFromAllDogsCollection:
                   return "https://dog.ceo/api/breeds/image/random"
                    
                case .randomImageForBreed(let breed):
                    return "https://dog.ceo/api/breed/\(breed)/images/random"
                    
                case .listAllBreeds:
                    return "https://dog.ceo/api/breeds/list/all"
                }
            }
        }
    
    // MARK: Reeuest Breed List
    
    class func requestBreedsList(completionHandler: @escaping ([String], Error?) -> Void) {
        // URLSession created for all breeds list
        let task = URLSession.shared.dataTask(with: Endpoint.listAllBreeds.url) { (data, response, error) in
            guard let data = data else{
                completionHandler([], error)
                return
            }
            // Decode the breeds list into a hash map
            let decoder = JSONDecoder()
            let breedsResponse = try! decoder.decode(BreedsListResponse.self, from: data)
            let breeds = breedsResponse.message.keys.map({$0})
            completionHandler(breeds,nil)
        }
        task.resume()
    }
    
    // MARK: Request Random Image - return URLImage String
    
    class func requestRandomImage(breed: String, completionHandler: @escaping (DogImage?, Error?) -> Void){
            
        // Endpoint for random image
        let randomImageEndpoint = DogAPI.Endpoint.randomImageForBreed(breed).url
            
        // URLSession created for requesting a random image
        let task = URLSession.shared.dataTask(with: randomImageEndpoint) { (data, response, error) in
            guard let data = data else{
                completionHandler(nil, error)
                return
            }
            // Decode the Dog Image
            let decoder = JSONDecoder()
            let imageData = try! decoder.decode(DogImage.self, from: data)
            completionHandler(imageData, nil)
        }
        task.resume()
    }
    
    // MARK: Request Image from Random image - returns UIImage
    
    class func requestImageFile(url: URL, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        
        // URLSession created for requesting image
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            let downloadedImage = UIImage(data: data)
            completionHandler(downloadedImage, nil)
        }
        task.resume()
    }
    
    
}
