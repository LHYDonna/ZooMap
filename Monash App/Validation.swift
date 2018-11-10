//
//  Validation.swift
//  Monash App
//
//  Created by 林洪钰 on 5/9/18.
//  Copyright © 2018 林洪钰. All rights reserved.
//

import UIKit
import CoreData

class Validation: NSObject {
    
    var animalList: [Animal] = []
    var managedObjectContext: NSManagedObjectContext
    var appDelegate: AppDelegate?
    
    override init() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
    }
    
    // get animalList from core data
    func initialList(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Animal")
        do{
            animalList = try managedObjectContext.fetch(fetchRequest) as! [Animal]
        }
        catch{
            fatalError("Failed to fetch any animals: \(error)")
        }
    }
    
    // check if the new address added already marked on the map
    func checkRepeatPosition(_ lat: String, _ lon: String) -> Bool{
        initialList()
        for animal in animalList{
            if ((animal.lat?.elementsEqual(lat))! && (animal.lon?.elementsEqual(lon))!){
                return false
            }
        }
        return true
    }
    
    // check if name is valid
    // must not be blank
    // must not contain special characters or numbers
    // do not accept space
    // no more than 10 characters
    func checkNameValid(_ newName: String) ->Bool{
        if (checkStringNotBlank(newName) && checkStringLegal(newName) && checkStringLength(newName,10)){
            return true
        }
        return false
    }
    
    // check if name is valid
    // must not be blank
    // must not contain special characters or numbers
    // no more than 15 characters
    func checkDescValid(_ newDesc: String) ->Bool{
        if (checkStringLegal(newDesc.replacingOccurrences(of: " ", with: "")) && checkStringNotBlank(newDesc) && checkStringLength(newDesc,15)){
            return true
        }
        return false
    }
    
    // check string not blank
    func checkStringNotBlank(_ AString: String) ->Bool{
        let chars = AString.trimmingCharacters(in: .whitespacesAndNewlines)
        if (chars != ""){
            return true
        }
        return false
    }
    
    // check string is made of letters only
    func checkStringLegal(_ AString: String) ->Bool{
        for chr in AString {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
    
    // check string length no more than 15 characters
    func checkStringLength(_ AString: String, _ length: Int) -> Bool{
        if (AString.count > length){
            return false
        }
        return true
    }
    
}
