//
//  MapViewController.swift
//  Map Share
//
//  Created by Elon Rubin on 11/30/16.
//  Copyright © 2016 Elon Rubin. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    //--------------------------------------
    // MARK: Variables
    //--------------------------------------
    var lat: Double = 0.0
    var long: Double = 0.0
    var place: Place?
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    
    //--------------------------------------
    // MARK: Functions
    //--------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // this loads the map, data and creates a pin
        configureMap()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func configureMap () {
        
        
        if let place = place {
        let location = CLLocationCoordinate2DMake(place.lat,place.long)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView!.setRegion(region, animated: true)
    
            // Creates annnotation
        let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = place.name
            annotation.subtitle = place.address
                    mapView!.addAnnotation(annotation)
            mapView!.selectAnnotation(annotation, animated: false )
            if #available(iOS 9.0, *) {
                mapView!.mapType = MKMapType.hybridFlyover
            } else {
                // Fallback on earlier versions
            }
            mapView!.reloadInputViews()
        }
        
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
    }
    
}
