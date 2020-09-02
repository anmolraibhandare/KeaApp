//
//  UserData.swift
//  Kea
//
//  Created by Anmol Raibhandare on 9/1/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//

import Foundation
import UIKit

class UserData {
    var firstname = ""
    var lastname = ""
    var userid = ""
    
    init(firstname: String, lastname: String, uid: String) {
        self.firstname = firstname
        self.lastname = lastname
        self.userid = uid
    }
}
