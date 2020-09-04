//
//  PetData.swift
//  Kea
//
//  Created by Anmol Raibhandare on 9/1/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//

import Foundation
import UIKit

class PetData {
    var name = ""
    var kind = ""
    var picture: UIImage?
    var dob = Date()
    
    private let names = ["Eddie", "Kimchi", "Meetkit", "Handel", "Kinginthenorth", "Rockzilla", "Kuro" ]
    private let kinds = ["Dog", "Cat"]
    
    init() {
        var index = Int(arc4random_uniform(UInt32(names.count)))
        name = names[index]
        index = Int(arc4random_uniform(UInt32(kinds.count)))
        kind = kinds[index]
    }
}
