//
//  StudySpotsMapViewController.swift
//  LyKarenFinalProject
//
//  Created by Karen Ly on 12/1/22.
//
//  Name: Karen Ly
//  Email: karenly@usc.edu

import UIKit
import MapKit
import CoreLocation

// View Controller for displaying study spots on a map
class StudySpotsMapViewController: UIViewController {
    private var reviewsService = ReviewsService.shared

    @IBOutlet weak var mapView: MKMapView!
    
    // Reload map with annotations
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        // Set initial region of map to USC
        let center = CLLocationCoordinate2D(latitude: 34.0224, longitude: -118.2851)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        mapView.region = MKCoordinateRegion(center: center, span: span)
        addStudySpotsPins()
    }
    
    // Display all the study spot locations on map
    func addStudySpotsPins() {
        // Remove any previous annotations
        mapView.removeAnnotations(mapView.annotations)
        // For each study spot review, display study spot location
        for review in reviewsService.studySpotReviews {
            getCoordinate(addressString: review.studySpot.address.getAddress()) { coordinate, error in
                // If able to get coordinate, then add the annotation
                if error == nil {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    annotation.title = review.studySpot.name
                    annotation.subtitle = review.studySpot.address.getAddress()
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    // Returns the corresponding coordinate from address string
    func getCoordinate(addressString : String,
                       completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            // Was able to get coordinate results
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            // Unable to get coordinate results
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
}
