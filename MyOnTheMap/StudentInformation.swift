//
//  StudentInformation.swift
//  MyOnTheMap
//
//  Created by Jason Crawford on 11/28/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var createdAt: String
    let firstName: String
    let lastName: String
    var latitude: Float
    var longitude: Float
    var mapString: String
    var mediaURL: String
    var objectId: String
    let uniqueKey: String
    var updatedAt: String
    
    // Construct student information from dictionary
    
    init?(dictionary: [String: AnyObject]) {
        
        guard let created = dictionary["createdAt"] as? String else { return nil }
        createdAt = created
        
        guard let first = dictionary["firstName"] as? String else { return nil }
        firstName = first
        
        guard let last = dictionary["lastName"] as? String else { return nil }
        lastName = last
        
        guard let lat = dictionary["latitude"] as? Float else { return nil }
        latitude = lat
        
        guard let lon = dictionary["longitude"] as? Float else { return nil }
        longitude = lon
        
        guard let map = dictionary["mapString"] as? String else { return nil }
        mapString = map
        
        guard let media = dictionary["mediaURL"] as? String else { return nil }
        mediaURL = media
        
        guard let object = dictionary["objectId"] as? String else { return nil }
        objectId = object
        
        guard let unique = dictionary["uniqueKey"] as? String else { return nil }
        uniqueKey = unique
        
        guard let updated = dictionary["updatedAt"] as? String else { return nil }
        updatedAt = updated
        
    }
    
    static func studentFromResult(results: [[String: AnyObject]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        
        for result in results {
            
            if let studentInfo = StudentInformation(dictionary: result) {
                students.append(studentInfo)
                
            }
            
        }
        
        return students
        
    }
    
}
