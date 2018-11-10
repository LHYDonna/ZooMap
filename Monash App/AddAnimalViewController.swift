//
//  AddAnimalViewController.swift
//  Monash App
//
//  Created by 林洪钰 on 22/8/18.
//  Copyright © 2018 林洪钰. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

protocol AddAnimalProtocol {
    func addAnimal(animal:Animal) -> Bool
    func editAnimal(animal:Animal, index: Int)
}

protocol AnimalInfoDelegate {
    //func setPhotoName(_ filename: String?)
    func setIconName(_ filename: String?)
}

class AddAnimalViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,AnimalInfoDelegate{

    //private var name: String?
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var descText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var pinNameLabel: UILabel!
    
//    @IBOutlet var animalButtons: [UIButton]!
//    
//    
//    @IBAction func selectNameBtn(_ sender: UIButton) {
//        animalButtons.forEach{(button) in
//            UIView.animate(withDuration: 0.3, animations: {
//                button.isHidden = !button.isHidden
//                self.view.layoutIfNeeded()
//            })
//        }
//    }
//
//    @IBAction func selectAnAnimalbtn(_ sender: UIButton) {
//         let name = sender.currentTitle
//         print(name!)
//    }
    
    private var animal: Animal?
    private var validation: Validation?
    var managedObjectContext: NSManagedObjectContext
    var addAnimalDelegate: ManageAnimalProtocol?
    let locationManager = CLLocationManager()
    var moveToUserLocation = false
    var currentLocation: CLLocationCoordinate2D?
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinNameLabel.text = "default"
        pinImageView.image = UIImage(named: "default")
        let pinDroper = UILongPressGestureRecognizer(target: self, action: #selector(self.dropAnnotation(gestureRecogniser:)))
        pinDroper.minimumPressDuration = CFTimeInterval(2.0)
        view.addGestureRecognizer(pinDroper)
        
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Long hold to add an annotaion
    @objc func dropAnnotation(gestureRecogniser: UIGestureRecognizer){
        if gestureRecogniser.state == .began{
            let holdLocation = gestureRecogniser.location(in: mapView)
            let coordinate = mapView.convert(holdLocation, toCoordinateFrom: mapView)
            // Add annotation
            clearMap()
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = nameText.text
            mapView.addAnnotation(annotation)
            
            // Edit lat, lon and address
            getAddressFromLatLon(pdblLatitude: String(coordinate.latitude), withLongitude: String(coordinate.longitude))
            latitudeLabel.text = String(coordinate.latitude)
            longitudeLabel.text = String(coordinate.longitude)
        }
    }
    
    // Take picture using camera
    @IBAction func takePhotoBtn(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            controller.sourceType = UIImagePickerControllerSourceType.camera
        }
        else{
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller,animated: true, completion: nil)
    }
    
    // Import a picture from local storage
    @IBAction func importPicture(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true){
        }
    }
    
    // ImagePicker cancel action
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        createAltert(title: "There was an error in getting the photo", message: "Error")
        self.dismiss(animated: true, completion: nil)
    }
    
    // Add button, press to add a new animal to the core data
    @IBAction func addBtn(_ sender: UIButton) {
        //Storing core data
        validation = Validation()
        if !(validation?.checkNameValid(nameText.text!))!{
            createAltert(title: "Invalid Name", message: "Input a valid animal name please!")
            return
        }
        if !(validation?.checkDescValid(descText.text!))!{
            createAltert(title: "Invalid Description", message: "Input a valid animal description please!")
            return
        }
        if (latitudeLabel.text!.elementsEqual("Latitude ")){
            createAltert(title: "Address invalid", message: "Press and hold on the map to get a location!")
            return
        }
        if !(validation?.checkRepeatPosition(latitudeLabel.text!, longitudeLabel.text!))!{
            createAltert(title: "Address repeated", message: "Press and hold on the map to get another location!")
            return
        }
        else {
            let newAnimal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext) as! Animal
            newAnimal.setValue(nameText.text, forKey: "name")
            newAnimal.setValue(descText.text, forKey: "desc")
            newAnimal.setValue(locationText.text, forKey: "location")
            newAnimal.setValue(latitudeLabel.text, forKey: "lat")
            newAnimal.setValue(longitudeLabel.text, forKey: "lon")
            newAnimal.setValue(pinNameLabel.text, forKey: "pin")
            
            //Saving the image to core data
            savePicture(animal: newAnimal)
            addAnimalDelegate?.addAnimal(animal: newAnimal)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // Create alert
    func createAltert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Clear all the annotations on the map
    func clearMap(){
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    // Save picture
    func savePicture(animal: Animal){
        guard let image = pictureImageView.image else{
            //print("Cannot save until a photo has been taken!", "Error")
            animal.setValue("default_photo",forKey: "picture")
            return
        }
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.8)!
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(date)"){
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
            animal.setValue("\(date)", forKey: "picture")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            pictureImageView.image = image
        }
        else{
            //Error message
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Focusing on current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocation = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01))
            mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "You are here"
            mapView.addAnnotation(annotation)
            
            // Set Latitude and Longitude labels
            setLatLon(latidude:String(location.coordinate.latitude),longitude: String(location.coordinate.longitude))
            
            // Get address from current location
            getAddressFromLatLon(pdblLatitude: String(location.coordinate.latitude), withLongitude: String(location.coordinate.longitude))
        }
    }
    
    // Set latitude and longitude
    func setLatLon(latidude: String, longitude: String){
        latitudeLabel.text = latidude
        longitudeLabel.text = longitude
    }
    
    // Get address by latitude and longitude
    // Retrieved from "https://stackoverflow.com/questions/41358423/swift-generate-an-address-format-from-reverse-geocoding"
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String){
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        let lon: Double = Double("\(pdblLongitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        var addressString : String = ""
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    self.locationText.text = addressString
                }
        })
    }

    
    // Search address by the search button, zoom in and put an annotaion mark
    @IBAction func searchBtn(_ sender: Any) {
        let activityIndicator = UIActivityIndicatorView()
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = locationText.text

        let activeSearch = MKLocalSearch(request: searchRequest)

        activeSearch.start{(response,error) in

            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()

            if response == nil
            {
                print("error")
            }
            else
            {
                //remove annotations
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)

                //geting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude

                //create annotation
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                //annotation.title = self.nameText.text
                //annotation.subtitle = self.descText.text
                self.mapView.addAnnotation(annotation)

                //Zooming in on annotation
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
                self.mapView.setRegion(region, animated: true)

            }
       }
    }
    
    // Set icon name
    func setIconName(_ filename: String?) {
        self.pinNameLabel.text = filename!
        self.pinImageView.image = UIImage(named:filename!)
    }
    

    //navigate to IconCollectionViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SelectIconSegue"){
            let controller = segue.destination as! IconCollectionViewController
            controller.animalInfoDelegate = self
            controller.animalType = self.nameText.text
        }
    }

}
