//
//  Ingredient.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/21/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import Foundation

struct Ingredient {
    var originalName : String
    var name : String 
    var unit : String
    var amount : Int
    var id : Int
    
    func toDictionary() -> [String : Any] {
        var ingredientDictionary = [String : Any]()
        ingredientDictionary["originalName"] = originalName
        ingredientDictionary["name"] = name
        ingredientDictionary["unit"] = unit
        ingredientDictionary["amount"] = amount
        ingredientDictionary["id"] = id
        return ingredientDictionary
    }
}
