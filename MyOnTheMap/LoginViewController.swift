//
//  LoginViewController.swift
//  MyOnTheMap
//
//  Created by Jason Crawford on 11/20/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTapAnywhere()
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        setUIEnabled(enabled: false)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(enabled: false)
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Log user in
        // Request session ID
        UdacityClient.sharedInstance().getSessionId(username: usernameTextField.text!, password: passwordTextField.text!) { (userKey, error) in
            
            if let userKey = userKey {
                
                // Identify student with user key
                UdacityClient.sharedInstance().studentWithUserKey(userKey: userKey) { (success, error) in
                    
                    if success! {
                        self.completeLogin()
                    } else {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.displayAlert(message: error!)
                    }
                    
                }
                
            } else {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // Enable UI again and show error
                self.setUIEnabled(enabled: true)
                self.displayAlert(message: error!)
                
            }
            
        }
        
    }
    
    @IBAction func signUpPressed(_ sender: AnyObject) {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            displayAlert(message: "Something's not quite right. Please try again later.")
        }
    }
    
    // MARK: Hide keyboard when return key is pressed and perform submit action
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        loginButton.sendActions(for: .touchUpInside)
        return false
    }
    
    // MARK: Complete login
    
    func completeLogin() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        performUIUpdatesOnMain {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: UI state
    
    func setUIEnabled(enabled: Bool) {
        
        loginButton.isEnabled = enabled
        
        performUIUpdatesOnMain {
            // Set button title
            if enabled {
                self.loginButton.setTitle("LOGIN", for: UIControlState.normal)
            } else {
                self.loginButton.setTitle("We're logging you in...", for: UIControlState.disabled)
            }
        }
        
    }
    
}

    
