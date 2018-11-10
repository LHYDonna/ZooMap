//
//  AnimalListViewController.swift
//  Monash App
//
//  Created by 林洪钰 on 22/8/18.
//  Copyright © 2018 林洪钰. All rights reserved.
//

import UIKit
import CoreData
import MapKit

protocol ManageAnimalProtocol {
    func addAnimal(animal:Animal) -> Bool
    func editAnimal(animal: Animal, index: Int)
}

class AnimalListViewController: UITableViewController, UISearchResultsUpdating, ManageAnimalProtocol, CLLocationManagerDelegate{
    
    
    var animalList: [Animal]
    var filteredAnimalList:[Animal] = []
    var appDelegate: AppDelegate?
    var managedObjectContext: NSManagedObjectContext
    private var animalCell: AnimalCell?
    var mapViewController: ViewController?
    var locationManager: CLLocationManager = CLLocationManager()
    
    required init?(coder aDecoder: NSCoder) {
        animalList = []
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self

        //clear all the data
        //deleteAllObject()
        
        //initial List
        initialList()
        
        //manage filteredList
        filteredAnimalList = animalList
        
        // Load map
        self.mapViewController?.reloadAnnotations()
        
        // Load tableview
        tableView.reloadData()
        
        // Search controller
        searchAnimal()
    }
    
    // Get data from core data
    func initialList(){

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Animal")
        do{
            animalList = try managedObjectContext.fetch(fetchRequest) as! [Animal]
            if animalList.count < 5{
                animalList = hardData()
            }
            for animal in animalList {
                self.mapViewController?.addAnnotation(animal)
            }
        }
        catch{
            fatalError("Failed to fetch any animals: \(error)")
        }
    }
    
    // Hard copy of virtial animals if there are no animals in the core data
    func hardData() ->[Animal]{
        let dogBlack = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext) as! Animal
        dogBlack.setAnimal(newName: "Dog", newLat: "-37.8783674003983", newLong: "145.046193552419", newDesc: "A black dog", newPin: "dog_black", newPicture: "default_photo", newLocation: "Monash")
        animalList.append(dogBlack)
        let dogYellow = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext) as! Animal
        dogYellow.setAnimal(newName: "Dog", newLat: "-37.8768600021726", newLong: "145.043146562549", newDesc: "A yellow dog", newPin: "dog_yellow", newPicture: "default_photo", newLocation: "Monash")
        animalList.append(dogYellow)
        let catYellow = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext) as! Animal
        catYellow.setAnimal(newName: "Cat", newLat: "-37.8771987460341", newLong: "145.044176530956", newDesc: "A yellow cat", newPin: "cat_yellow", newPicture: "default_photo", newLocation: "Monash")
        animalList.append(catYellow)
        let catBlack = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext) as! Animal
        catBlack.setAnimal(newName: "Cat", newLat: "-37.8790109992321", newLong: "145.045163584012", newDesc: "A black cat", newPin: "cat_black", newPicture: "default_photo", newLocation: "Monash")
        animalList.append(catBlack)
        let snakeBlack = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext) as! Animal
        snakeBlack.setAnimal(newName: "Snake", newLat: "-37.8792819865323", newLong: "145.04649395987", newDesc: "A black snake", newPin: "snake_black", newPicture: "default_photo", newLocation: "Monash")
        animalList.append(snakeBlack)
        return animalList
    }
    
    // Search function
    func searchAnimal(){
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater  = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by name"
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
    }
    
    // AddDelegate function
    func addAnimal(animal:Animal) ->Bool{
        animalList.append(animal)
        self.mapViewController?.addAnnotation(animal)
        self.mapViewController?.reloadAnnotations()
        filteredAnimalList = animalList
        tableView.reloadData()
        saveData()
        return true
    }
    
    // EditDelegate function
    func editAnimal(animal: Animal, index: Int) {
        animalList[index] = animal
        filteredAnimalList = animalList
        self.mapViewController?.editAnnotation(animal,index)
        self.mapViewController?.reloadAnnotations()
        tableView.reloadData()
        saveData()
    }
    
    // Clear all the objects
    func deleteAllObject() {
        print ("-----------------------")
        print ("method: deleteAllObject called")
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Animal")
        do {
            for object in try managedObjectContext.fetch(fetchRequest) {
                managedObjectContext.delete(object)
            }
            try managedObjectContext.save()
        }
        catch let error {
            fatalError("Failed to fetch teams: \(error)")
        }
    }
    
    // Save to core data
    func saveData(){
        do{
            try managedObjectContext.save()
            print("SAVED")
        }
        catch let error{
            print("Could not save Core Data: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Search results updating
    func updateSearchResults(for searchController: UISearchController){
        if let searchText = searchController.searchBar.text,searchText.count>0{
            filteredAnimalList = animalList.filter({ (animal: Animal) -> Bool in
                return animal.name!.contains(searchText)
            })
        }
        else{
            filteredAnimalList = animalList
        }
        tableView.reloadData()
    }
    
    // Sorting results updating
    @IBAction func descentSortBtn(_ sender: Any) {
        animalList.sort(by: { UIContentSizeCategory(rawValue: $0.name!).rawValue >= UIContentSizeCategory(rawValue: $1.name!).rawValue })
        filteredAnimalList = animalList
        tableView.reloadData()
    }
    
    // Sorting results updating
    @IBAction func acsentSortBtn(_ sender: Any) {
        animalList.sort(by: { UIContentSizeCategory(rawValue: $0.name!).rawValue <= UIContentSizeCategory(rawValue: $1.name!).rawValue })
        filteredAnimalList = animalList
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredAnimalList.count
    }
    
    // fill in cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath) as! AnimalCell
        
        // Configure the cell...
        let animal: Animal = self.filteredAnimalList[indexPath.row]
        cell.nameLabel.text = animal.name
        cell.descLabel.text = animal.desc
        cell.addressLabel.text = animal.location
        cell.pinImage.image = UIImage(named: animal.pin!)
        return cell
    }
    
    // Define the height of the cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    // zoom to selected animal on the mapView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mapViewController?.focusOn(newLat: animalList[indexPath.row].lat!, newLon: animalList[indexPath.row].lon!)
        if UIDevice.current.orientation == .portrait{
            self.navigationController?.pushViewController(mapViewController!, animated: true)
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let animalDelete = animalList.remove(at: indexPath.row)
            filteredAnimalList = animalList
            managedObjectContext.delete(animalDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.mapViewController?.annotationList.remove(at: indexPath.row)
            self.mapViewController?.animalList.remove(at: indexPath.row)
            self.mapViewController?.reloadAnnotations()
            tableView.reloadData()
            saveData()
        }
    }
    
    // Geofencing
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "Moverment Detected!", message: "You have enter \(region.identifier)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Navigate to AddAnimalViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAnimalSegue" {
            print("++++++++++++++++++++++++++1")
            let controller = segue.destination as! AddAnimalViewController
            controller.addAnimalDelegate = self
            controller.managedObjectContext = self.managedObjectContext
        }
    }
    
}
