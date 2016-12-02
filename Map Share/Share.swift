//
//  Tasks.swift
//  Timely
//
//  Created by Elon Rubin on 11/10/16.
//  Copyright © 2016 Elon Rubin. All rights reserved.
//

import Foundation
import RealmSwift

class Share: Object {
    
    dynamic var placeName:String = ""
    dynamic var id:Int = 0
    dynamic var sentOrRecieved:String = ""
    dynamic var sentToOrRecievedBy:String = ""
    dynamic var lat:Double = 0.0
    dynamic var long:Double = 0.0
    dynamic var creationDate = Date()
    dynamic var creationDateString = ""
    override static func primaryKey() -> String?
    {
        return "id";
    }
    
}
