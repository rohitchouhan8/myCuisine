//
//  Instruction.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/27/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import Foundation

struct Instruction {
    var number : Int
    var step : String
    
    func toDictionary() -> [String : Any] {
        return ["number" : number, "step" : step]
    }
}
