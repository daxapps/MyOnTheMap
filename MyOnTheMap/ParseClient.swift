//
//  ParseClient.swift
//  MyOnTheMap
//
//  Created by Jason Crawford on 11/21/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import Foundation

class ParseClient {
    
    // MARK: Properties
    
    let session = URLSession.shared
    
    // MARK: GET student locations
    
    func getStudentLocations(completionHandler: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        
        /* Configure the request */
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* Make the request */
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, "Sorry, we couldn't download any student locations. PLease try again later.")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(false, "Your request didn't return any data. Please try again later.")
                return
            }
            
            /* Parse and use data */
            if let parsedResult = (try! JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: AnyObject] {
                StudentModel.sharedInstance.students = StudentInformation.studentFromResult(results: parsedResult["results"] as! [[String: AnyObject]])
            }
            
            completionHandler(true, nil)
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        task.resume()
    }
    
    // MARK: GET location(s) posted by current user
    
    func getUserLocation(userKey: String, completionHandler: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        
        /* Configure the request */
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(userKey)%22%7D")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* Make the request */
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, "Something's not quite right, please try again later.")
                return
            }
            
            /* Parse and use data */
            if let parsedResult = (try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? [String: AnyObject] {
                
                // This could return multiple user locations
                let userLocations = parsedResult["results"] as! [[String: AnyObject]]
                
                // We'll use the last location, which would be the most recent one
                // Test if it exists and if it does, store it in user data model
                if let userLatitude = userLocations.last?["latitude"] as? Double {
                    UserInformation.latitude = userLatitude
                }
                
                if let userLongitude = userLocations.last?["longitude"] as? Double {
                    UserInformation.longitude = userLongitude
                }
                
                if let userMapString = userLocations.last?["mapString"] as? String {
                    UserInformation.mapString = userMapString
                }
                
                if let userMediaURL = userLocations.last?["mediaURL"] as? String {
                    UserInformation.mediaURL = userMediaURL
                }
                
                if let userObjectId = userLocations.last?["objectId"] as? String {
                    UserInformation.objectId = userObjectId
                }
            }
            
            completionHandler(true, nil)
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        task.resume()
    }
    
    // MARK: POST current user's location
    
    func postUserLocation(userKey: String, firstName: String, lastName: String, mediaURL: String, mapString: String, latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        /* Configure the request */
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(userKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
        /* Make the request */
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, "Sorry, we couldn't post your location. Please try again later.")
                return
            }
            
            completionHandler(true, nil)
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        task.resume()
    }
    
    // MARK: PUT (update) current user's location
    
    func updateUserLocation(userKey: String, firstName: String, lastName: String, mediaURL: String, mapString: String, latitude: Double, longitude: Double, objectId: String, completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        /* Configure the request */
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/\(objectId)")!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(userKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
        /* Make the request */
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, "Sorry, we couldn't update your location. Please try again later.")
                return
            }
            
            completionHandler(true, nil)
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        task.resume()
    }
    
    // MARK: DELETE current user's location  
    
    func deleteUserLocation(objectId: String, completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        /* Configure the request */
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/\(objectId)")!)
        request.httpMethod = "DELETE"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* Make the request */
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, "Sorry, we couldn't delete your location. Please try again later.")
                return
            }
            
            completionHandler(true, nil)
        }
        
        task.resume()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}
