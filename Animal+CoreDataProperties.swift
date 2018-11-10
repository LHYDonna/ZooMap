//
//  Animal+CoreDataProperties.swift
//  
//
//  Created by 林洪钰 on 31/8/18.
//
//

import Foundation
import CoreData


extension Animal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Animal> {
        return NSFetchRequest<Animal>(entityName: "Animal")
    }

    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var location: String?
    @NSManaged public var picture: String?
    @NSManaged public var pin: String?
    @NSManaged public var lat: String?
    @NSManaged public var lon: String?
    
    func setAnimal(newName: String, newLat: String, newLong: String, newDesc: String, newPin: String, newPicture: String, newLocation: String) {
        name = newName
        lat = newLat
        lon = newLong
        desc = newDesc
        pin = newPin
        picture = newPicture
        location = newLocation
    }
}
