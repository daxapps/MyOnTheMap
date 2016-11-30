//
//  TableViewController.swift
//  MyOnTheMap
//
//  Created by Jason Crawford on 11/20/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        ParseClient.sharedInstance().getStudentLocations() { (success, error) in
            
            if success! {
                
                // Reload table data
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            } else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(message: error!)
            }
        }
    }
    
    // Set number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.sharedInstance.students.count
    }
    
    // Configure table cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        let studentTable = StudentModel.sharedInstance.students[indexPath.row]
        
        cell.textLabel?.text = studentTable.firstName + " " + studentTable.lastName
        cell.detailTextLabel?.text = studentTable.mapString.capitalized
        
        return cell
    }
    
    // Tap on table cell opens student's weblink
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Make sure URL is in correct format
        if let url = URL(string: Helpers.sharedInstance().formatURL(url: StudentModel.sharedInstance.students[indexPath.row].mediaURL)) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: Swipe to delete user information
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // Check if row belongs to current user
        // This is to make sure users can only delete their own information
        let thisRowStudent = StudentModel.sharedInstance.students[indexPath.row]
        return thisRowStudent.uniqueKey == UserInformation.userKey
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // Identify student for this row
            let thisRowStudent = StudentModel.sharedInstance.students[indexPath.row]
            
            // Remove the row
            StudentModel.sharedInstance.students.remove(at: indexPath.row)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            // Remove user from Parse database
            ParseClient.sharedInstance().deleteUserLocation(objectId: thisRowStudent.objectId) { (success, error) in
                if success {
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    // Reset user information locally
                    // There's only one API call in map view to check whether current user has posted before
                    // So this is to keep track of things internally
                    UserInformation.latitude = 0.00
                    UserInformation.longitude = 0.00
                    UserInformation.mapString = ""
                    UserInformation.mediaURL = ""
                    UserInformation.objectId = ""
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlert(message: error!)
                }
            }
            
            performUIUpdatesOnMain {
                self.tableView.reloadData()
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
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            } else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(message: error!)
            }
        }
    }    
}

