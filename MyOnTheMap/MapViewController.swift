//
//  MapViewController.swift
//  MyOnTheMap
//
//  Created by Jason Crawford on 11/20/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if current user has already posted a location
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        ParseClient.sharedInstance().getUserLocation(userKey: UserInformation.userKey) { (success, error) in
            
            if success! {
                
                // If user is already on map, center map on coordinates they posted
                
                if UserInformation.latitude != 0.00 && UserInformation.longitude != 0.00 {
                    
                    performUIUpdatesOnMain {
                        let location = CLLocationCoordinate2D(latitude: UserInformation.latitude, longitude: UserInformation.longitude)
                        let span = MKCoordinateSpanMake(10, 10)
                        let region = MKCoordinateRegion(center: location, span: span)
                        self.mapView.setRegion(region, animated: true)
                    }
                    
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            } else {
                
                self.displayAlert(message: error!)
                
            }
            
        }
        
        // Get student locations
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        ParseClient.sharedInstance().getStudentLocations() { (success, error) in
            
            if success! {
                
                // Remove annotations and repopulate map
                performUIUpdatesOnMain {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.populateMap()
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            } else {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(message: error!)
                
            }
            
        }
        
    }
    
    // MARK: Actions
    
    @IBAction func logoutPressed(_ sender: AnyObject) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        UdacityClient.sharedInstance().deleteSession() { (success, error) in
            
            if success {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                performUIUpdatesOnMain {
                    let viewController = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                    self.present(viewController, animated: true, completion: nil)
                }
                
            } else {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(message: error!)
                
            }
        }
        
    }
    
    @IBAction func refreshPressed(_ sender: AnyObject) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        ParseClient.sharedInstance().getStudentLocations() { (success, error) in
            
            if success! {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // Remove map annotations and repopulate
                performUIUpdatesOnMain {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.populateMap()
                }
                
            } else {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(message: error!)
                
            }
            
        }
        
    }
    
    // MARK: Function to populate map with students
    
    func populateMap(){
        
        // Store map annotations
        var annotations = [MKPointAnnotation]()
        
        for s in StudentModel.sharedInstance.students {
            
            // Create coordinate from latitude and longitude
            let lat = CLLocationDegrees(s.latitude)
            let lon = CLLocationDegrees(s.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            // Create map annotation with coordinate, name and media URL
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(s.firstName) \(s.lastName)"
            annotation.subtitle = s.mediaURL
            
            // Add annotation to array
            annotations.append(annotation)
        }
        
        // Add annotations to map
        mapView.addAnnotations(annotations)
        
    }
    
    // MARK: Open annotation's mediaURL in browser when tapped
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MapViewAnnotation")
        view.canShowCallout = true
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Make sure URL is in correct format
        let mediaURL = URL(string: Helpers.sharedInstance().formatURL(url: ((view.annotation?.subtitle)!)!))
        UIApplication.shared.open(mediaURL!, options: [:], completionHandler: nil)
    }
    
}

