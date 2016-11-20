//
//  GCDBlackBox.swift
//  MyOnTheMap
//
//  Created by Jason Crawford on 11/20/16.
//  Copyright © 2016 Jason Crawford. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
