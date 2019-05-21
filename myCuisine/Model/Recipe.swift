//
//  Recipe.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/21/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import Foundation

struct Recipe {
    var id : Int
    var preparationMinutes : Int
    var cookingMinutes : Int
    var readyInMinutes : Int
    var aggregateLikes : Int
    var healthScore : Int
    var sourceURL : String
    var imageURL : String
    var creditText : String
    var title : String
    var ingredients : [Ingredient]
    var instructions : String
    var diets : [String]
}
