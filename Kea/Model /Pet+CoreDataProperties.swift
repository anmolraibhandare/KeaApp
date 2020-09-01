//
//  Pet+CoreDataProperties.swift
//  
//
//  Created by Anmol Raibhandare on 9/1/20.
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
