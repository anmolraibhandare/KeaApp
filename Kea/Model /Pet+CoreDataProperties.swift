//
//  Pet+CoreDataProperties.swift
//  Kea
//
//  Created by Anmol Raibhandare on 9/1/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//
//

import Foundation
import CoreData


extension Pet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pet> {
        return NSFetchRequest<Pet>(entityName: "Pet")
    }

    @NSManaged public var dob: Date?
    @NSManaged public var kind: String?
    @NSManaged public var name: String?
    @NSManaged public var picture: Data?
    @NSManaged public var owner: User?

}
