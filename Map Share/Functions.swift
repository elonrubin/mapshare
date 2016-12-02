//
//  Functions.swift
//  Map Share
//
//  Created by Elon Rubin on 12/1/16.
//  Copyright © 2016 Elon Rubin. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import CoreLocation
import MapKit

class SwiftMethods {
    
    
    
    // 1 - returns current date in NSDate and String Format. This is used when saving a sent or recieved shared place
    
    static func getCurrentDate () -> (currentDate:Date, convertedDate: String) {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        
        let convertedDate = dateFormatter.string(from: currentDate)
        return (currentDate, convertedDate)
    }
    
    // 2 - this is used to update UI on main
    
    static func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    // 3 - used to create unique ID when saving a sent or recieved place
    func generateRandomNumber () -> String {
        let number: UInt32 =  1000000
         let randomNumber = Int(arc4random_uniform(number))
        
        return String(randomNumber)
    }
    
 
    
    
}
