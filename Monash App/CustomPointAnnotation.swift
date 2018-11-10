//
//  CustomPointAnnotation.swift
//  Monash App
//
//  Created by 林洪钰 on 7/9/18.
//  Copyright © 2018 林洪钰. All rights reserved.
//

import UIKit
import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    
    var imageName: String!
    var geoLocation: CLCircularRegion?
    
    init(_ animal: Animal) {
        super.init()
        if let lat = Double(animal.lat!),let lon = Double(animal.lon!) {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            print("Not a valid number")
        }
        title = animal.name
        subtitle = animal.desc
        imageName = animal.pin
        geoLocation = CLCircularRegion(center: coordinate, radius: 5, identifier: title!)
        geoLocation?.notifyOnEntry = true
    }
}
