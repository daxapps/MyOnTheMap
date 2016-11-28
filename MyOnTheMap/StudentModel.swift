//
//  StudentModel.swift
//  MyOnTheMap
//
//  Created by Jason Crawford on 11/28/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import Foundation

// MARK: Student model

class StudentModel {
    
    var students: [StudentInformation] = []
    
    static let sharedInstance = StudentModel()
}
