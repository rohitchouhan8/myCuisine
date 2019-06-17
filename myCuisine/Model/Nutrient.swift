//
//  Nutrient.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 6/15/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import Foundation

struct Nutrient {
    var name : String
    var amount : Int
    var unit : String
    var percentOfDailyNeeds : Double
    
    func toDictionary() -> [String : Any] {
        return [
                "name" : name,
                "amount" : amount,
                "unit" : unit,
                "percentOfDailyNeeds" : percentOfDailyNeeds
                ]
    }
    
    func toDetailItem() -> DetailItem {
        return DetailItem(main: name, detail: String(amount) + " " + unit)
    }
}
