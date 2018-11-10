//
//  ViewController.swift
//  Monash App
//
//  Created by 林洪钰 on 22/8/18.
//  Copyright © 2018 林洪钰. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation


class ViewController: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var animalListController: AnimalListViewController?
    
    var animalList: [Animal] = []
    var annotationList: [CustomPointAnnotation] = []
    var anAnimal: Animal?
    var currentIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
    }
    
    // Add customerPointAnnotations based on animals
    func addAnnotation(_ animal: Animal){
        animalList.append(animal)
        let annotation = CustomPointAnnotation(animal)
        self.annotationList.append(annotation)
        self.animalListController?.locationManager.startMonitoring(for: annotation.geoLocation!)
    }
    
    // Edit Annotation based on the index and animal
    func editAnnotation(_ animal: Animal,_ index: Int){
        let annotation = CustomPointAnnotation(animal)
        self.annotationList[index] = annotation
    }
    
    // Load all the annotations on the map
    func reloadAnnotations() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.showAnnotations(self.annotationList, animated: true)
    }
    
    // Add annotationView on the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            print("Not registered as MKPointAnnotation")
            return nil
        }
        let reuseId = "identifier"
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //add a button on the callout
        let btn = UIButton(type: .infoDark) as UIButton
        anView!.rightCalloutAccessoryView = btn
        
        let cpa = annotation as! CustomPointAnnotation
        anView!.image = UIImage(named:cpa.imageName)
        return anView
    }
    
    // Focus on one annotaion
    func focusOn(newLat: String, newLon: String){
        for annotation in annotationList{
            if (String(annotation.coordinate.latitude).elementsEqual(newLat) && String(annotation.coordinate.longitude).elementsEqual(newLon)){
                self.mapView.centerCoordinate = annotation.coordinate
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    //when the button is tapped perform a segue
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let numLat = NSNumber(value: (view.annotation?.coordinate.latitude)! as Double)
        let stLat:String = numLat.stringValue
        let numLon = NSNumber(value: (view.annotation?.coordinate.longitude)! as Double)
        let stLon:String = numLon.stringValue
        currentIndex = 0
        for animal in animalList{
            if !((animal.lat?.elementsEqual(stLat))! && (animal.lon?.elementsEqual(stLon))!){
                currentIndex = currentIndex! + 1
            }
            else{
                break
            }
        }
        anAnimal = animalList[currentIndex!]
        performSegue(withIdentifier: "animalDetail", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Navigate to AddAnimalViewController and DetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAnimalSegue" {
            let controller = segue.destination as! AddAnimalViewController
            controller.addAnimalDelegate = self.animalListController
            controller.managedObjectContext = self.animalListController!.managedObjectContext
        }
        if segue.identifier == "animalDetail" {
            let detailController = segue.destination as! DetailViewController
            detailController.editAnimalDelegate = self.animalListController
            detailController.animal = anAnimal
            detailController.index = currentIndex
        }
    }

}

