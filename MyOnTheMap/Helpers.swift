//
//  Helpers.swift
//  MyOnTheMap
//
//  Created by Jason Crawford on 11/28/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import Foundation
import UIKit

class Helpers: NSObject {
    
    // MARK: Format URLs
    
    func formatURL(url: String) -> String {
        var formattedURL = url
        if formattedURL.characters.first != "h"  && formattedURL.characters.first != "H"{
            formattedURL = "http://\(formattedURL)"
        }
        return String(formattedURL.characters.filter { !" ".characters.contains($0) })
    }
    
    // MARK: Shared instance
    
    class func sharedInstance() -> Helpers {
        struct Singleton {
            static var sharedInstance = Helpers()
        }
        return Singleton.sharedInstance
    }
    
}

extension UIViewController {
    
    // MARK: Display alert
    
    func displayAlert(message: String, completionHandler: ((UIAlertAction) -> Void)? = nil) {
        performUIUpdatesOnMain {
            
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: completionHandler))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Tap anywhere dismisses keyboard
    
    func hideKeyboardWhenTapAnywhere() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
