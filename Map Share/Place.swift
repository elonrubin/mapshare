//
//  Place.swift
//  Map Share
//
//  Created by Elon Rubin on 12/1/16.
//  Copyright © 2016 Elon Rubin. All rights reserved.
//

import Foundation
import RealmSwift

class Place: Object {
    dynamic var id:String = ""
    dynamic var name:String = ""
    dynamic var sent:Bool = true
    dynamic var otherName:String = ""
    dynamic var address:String = ""
    dynamic var lat:Double = 0.00
    dynamic var long:Double = 0.00
    dynamic var createdDate = NSDate()
    dynamic var convertedDate: String = ""
    dynamic var picData = NSData()
    override static func primaryKey() -> String?
    {
        return "id";
    }
    
}
