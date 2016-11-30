//
//  InformationPostingViewController.swift
//  MyOnTheMap
//
//  Created by Jason Crawford on 11/28/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    // MARK: Properties
    
    enum UIState { case MapString, MediaURL }
    var uiState = "MapString"
    var placemark: CLPlacemark? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var studyingLabel: UILabel!
    @IBOutlet weak var postingMapView: MKMapView!
    @IBOutlet weak var topSectionView: UIView!
    @IBOutlet weak var midSectionView: UIView!
    @IBOutlet weak var bottomSectionView: UIView!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var mapStringTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performUIUpdatesOnMain {
            self.configureUI(state: .MapString)
        }
        
        hideKeyboardWhenTapAnywhere()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if user has already posted a location
        guard UserInformation.mapString.isEmpty else {
            displayAlert(message: "Looks like you already posted a location. If you continue, we'll update your previous location.")
            
            performUIUpdatesOnMain {
                // Set mapString text to previously posted location
                self.mapStringTextField.text = UserInformation.mapString.capitalized
            }
            return
        }
    }
    
    // MARK: Hide keyboard when return key is pressed and perform submit action
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        submitButton.sendActions(for: .touchUpInside)
        return false
    }
    
    // MARK: Validate URL
    
    func validateURL(_ url: String) -> Bool {
        let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
        if url.range(of: pattern, options: .regularExpression) != nil {
            return true
        }
        return false
    }
    
    // MARK: Automatically prefix hyperlinks with https
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            textField.text = "https://"
        }
    }
    
    // MARK: Actions
    
    @IBAction func cancelPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitPressed(_ sender: AnyObject) {
        if uiState == "MapString" {
            
            // Check for empty string
            if mapStringTextField.text!.isEmpty {
                displayAlert(message: "Please enter a location.")
                return
            }
            
            // Start geocoding process
            performUIUpdatesOnMain {
                
                // Show activity indicator
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                activityIndicator.center = self.view.center
                activityIndicator.startAnimating()
                self.view.addSubview(activityIndicator)
                
                let geocoder = CLGeocoder()
                
                geocoder.geocodeAddressString(self.mapStringTextField.text!, completionHandler: { (results, error) in
                    if let _ = error {
                        activityIndicator.stopAnimating()
                        self.displayAlert(message: "Sorry, we weren't able to geocode the string you entered.")
                    }
                    else if (results!.isEmpty){
                        activityIndicator.stopAnimating()
                        self.displayAlert(message: "Sorry, we couldn't find a matching location.")
                    } else {
                        activityIndicator.stopAnimating()
                        self.placemark = results![0]
                        self.configureUI(state: .MediaURL)
                        self.postingMapView.showAnnotations([MKPlacemark(placemark: self.placemark!)], animated: true)
                        
                        // See if we already have a mediaURL for this user
                        // If so, use it to prefill the relevant textfield
                        // Change submit button title accordingly
                        
                        if UserInformation.mediaURL != "" {
                            self.mediaURLTextField.text = UserInformation.mediaURL
                            self.submitButton.setTitle(" UPDATE ", for: UIControlState.normal)
                        }
                    }
                })
            }
        } else if uiState == "MediaURL" {
            
            // MediaURL view
            if UserInformation.objectId.isEmpty {
                
                // Check for empty string
                if mediaURLTextField.text!.isEmpty {
                    displayAlert(message: "Please enter a URL.")
                    return
                }
                
                // Validate URL
                if validateURL(mediaURLTextField.text!) == false {
                    displayAlert(message: "Please enter a valid URL.")
                    return
                }
                
                // MARK: Post user location to Parse
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                ParseClient.sharedInstance().postUserLocation(userKey: UserInformation.userKey, firstName: UserInformation.firstName, lastName: UserInformation.lastName, mediaURL: self.mediaURLTextField.text!, mapString: self.mapStringTextField.text!, latitude: self.placemark!.location!.coordinate.latitude, longitude: self.placemark!.location!.coordinate.longitude) { (success, error) in
                    
                    if success {
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        performUIUpdatesOnMain {
                            
                            // Set user's location coordinates to center the map on when view controller is dismissed
                            UserInformation.latitude = (self.placemark!.location!.coordinate.latitude)
                            UserInformation.longitude = (self.placemark!.location!.coordinate.longitude)
                            // Also keep track of other information entered by user
                            UserInformation.mapString = self.mapStringTextField.text!
                            UserInformation.mediaURL = self.mediaURLTextField.text!
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.displayAlert(message: error!)
                    }
                }
            } else {
                if mediaURLTextField.text!.isEmpty {
                    displayAlert(message: "Please enter a URL.")
                    return
                }
  
                if validateURL(mediaURLTextField.text!) == false {
                    displayAlert(message: "Please enter a valid URL.")
                    return
                }
                
                // MARK: Update user location on Parse
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                ParseClient.sharedInstance().updateUserLocation(userKey: UserInformation.userKey, firstName: UserInformation.firstName, lastName: UserInformation.lastName, mediaURL: self.mediaURLTextField.text!, mapString: self.mapStringTextField.text!, latitude: self.placemark!.location!.coordinate.latitude, longitude: self.placemark!.location!.coordinate.longitude, objectId: UserInformation.objectId) { (success, error) in
                    
                    if success {
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        performUIUpdatesOnMain {
                            
                            // Set user's location coordinates to center map on when view controller is dismissed
                            UserInformation.latitude = (self.placemark!.location!.coordinate.latitude)
                            UserInformation.longitude = (self.placemark!.location!.coordinate.longitude)
                            
                            UserInformation.mapString = self.mapStringTextField.text!
                            UserInformation.mediaURL = self.mediaURLTextField.text!
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.displayAlert(message: error!)
                    }
                }
            }
        }
    }
    
    // MARK: Configure UI
    
    func configureUI(state: UIState, location: CLLocationCoordinate2D? = nil) {
        
        // UI colors
        let UdacityBlue = UIColor(red: 0.01, green: 0.70, blue: 0.89, alpha: 1.0)
        let UdacityGrey = UIColor(red: 0.917, green: 0.917, blue: 0.917, alpha: 1.0)
        
        UIView.animate(withDuration: 1.0) {
            switch(state) {
            case .MapString:
                self.uiState = "MapString"
                self.postingMapView.isHidden = true
                self.topSectionView.backgroundColor = UdacityGrey
                self.midSectionView.backgroundColor = UdacityBlue
                self.bottomSectionView.backgroundColor = UdacityGrey
                self.mediaURLTextField.isHidden = true
                self.mapStringTextField.isHidden = false
                self.cancelButton.setTitleColor(UdacityBlue, for: .normal)
                self.submitButton.setTitle("Find on the Map", for: UIControlState.normal)
                self.submitButton.setTitleColor(UdacityBlue, for: .normal)
                self.submitButton.backgroundColor = UIColor.clear
                self.studyingLabel.isHidden = false
            case .MediaURL:
                if let location = location {
                    self.postingMapView.centerCoordinate = location
                }
                self.uiState = "MediaURL"
                self.postingMapView.isHidden = false
                self.topSectionView.backgroundColor = UdacityBlue
                self.midSectionView.backgroundColor = UIColor.clear
                self.bottomSectionView.backgroundColor = UIColor.clear
                self.mediaURLTextField.isHidden = false
                self.mapStringTextField.isHidden = true
                self.cancelButton.setTitleColor(UIColor.white, for: .normal)
                self.submitButton.setTitle("Submit", for: UIControlState.normal)
                self.submitButton.setTitleColor(UIColor.white, for: .normal)
                self.submitButton.backgroundColor = UdacityBlue
                self.studyingLabel.isHidden = true
            }
        }
    }
}
