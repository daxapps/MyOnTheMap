//
//  UdacityClient.swift
//  MyOnTheMap
//
//  Created by Jason Crawford on 11/20/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import Foundation

class UdacityClient {
    
    // MARK: Properties
    
    // Shared session
    var session = URLSession.shared
    
    // MARK: Request user key
    
    func getSessionId(username: String, password: String, completionHandler: @escaping (_ userKey: String?, _ error: String?) -> Void) {
        
        /* Configure the request */
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        /* Make the request */
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(nil, "Please check your internet connection.")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(nil, "Please make sure you enter a valid username and password.")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(nil, "Your request didn't return any data. Please try again later.")
                return
            }
            
            /* Skip security characters */
            let dataLength = data.count
            let r = 5...Int(dataLength)
            let newData = data.subdata(in: Range(r)) /* subset response data! */
            
            /* Parse and use data */
            if let parsedResult = (try! JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments)) as? NSDictionary {
                    if let userKey = (parsedResult["account"] as? [String: Any])?["key"] as? String {
                        UserInformation.userKey = userKey
                        completionHandler(userKey, nil)
                    }
            }
        }
        
        task.resume()
    }
    
    // MARK: Identify user with key
    
    func studentWithUserKey(userKey: String, completionHandler: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        
        /* Configure the request */
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(userKey)")!)
        
        /* Make the request */
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(nil, "Oops, looks like you're not connected to the internet.")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(nil, "Your request didn't return any data. Please try again later.")
                return
            }
            
            /* Skip security characters */
            let dataLength = data.count
            let r = 5...Int(dataLength)
            let newData = data.subdata(in: Range(r)) /* subset response data! */
            
            /* Parse and use data */
            if let parsedResult = (try! JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments)) as? NSDictionary {
                    let userData = parsedResult["user"] as! NSDictionary
                    let firstName = userData["first_name"] as! String
                    let lastName = userData["last_name"] as! String
                    UserInformation.firstName = firstName
                    UserInformation.lastName = lastName
            }
            
            completionHandler(true, nil)
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        task.resume()
    }
    
    // MARK: DELETE session (logout)
    
    func deleteSession(completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        /* Configure the request */
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        /* Make the request */
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, "We weren't able to log you out. Please try again later.")
                return
            }
            
            completionHandler(true, nil)
        }
        
        task.resume()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}
