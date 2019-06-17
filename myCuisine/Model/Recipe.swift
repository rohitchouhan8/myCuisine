//
//  Recipe.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/21/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import Foundation
import Firebase

struct Recipe {
    var id : Int
    var preparationMinutes : Int
    var cookingMinutes : Int
    var readyInMinutes : Int
    var aggregateLikes : Int
    var healthScore : Int
    var servings : Int 
    var sourceURL : String
    var imageURL : String
    var creditText : String
    var title : String
    var ingredients : [Ingredient]
    var instructions : [Instruction]
    var diets : [String]
    var cuisines : [String]
    var nutrients : [Nutrient]
    
    let db = Firestore.firestore()
    
    func formatIngredients() -> String {
        var string = ""
        for ing in ingredients {
            string += String(ing.amount) + " " +  ing.unit + " " + ing.originalName + "\n"
        }
        return string
    }
    
    
    
    func formatToSave() -> [String : Any] {
        var recipeDict = [String : Any]()
        recipeDict["id"] = id
        recipeDict["preparationMinutes"] = preparationMinutes
        recipeDict["readyInMinutes"] = readyInMinutes
        recipeDict["cookingMinutes"] = cookingMinutes
        recipeDict["aggregateLikes"] = aggregateLikes
        recipeDict["healthScore"] = healthScore
        recipeDict["sourceURL"] = sourceURL
        recipeDict["imageURL"] = imageURL
        recipeDict["creditText"] = creditText
        recipeDict["title"] = title
        
        recipeDict["diets"] = diets
        recipeDict["cuisines"] = cuisines
        recipeDict["servings"] = servings
        
        var ingredientArray = [[String : Any]]()
        for ing in ingredients {
            ingredientArray.append(ing.toDictionary())
        }
        recipeDict["ingredients"] = ingredientArray
        
        var instructionArray = [[String : Any]]()
        for inst in instructions {
            instructionArray.append(inst.toDictionary())
        }
    
        recipeDict["instructions"] = instructionArray
        
        var nutrientArray = [[String : Any]]()
        for nutrient in nutrients {
            nutrientArray.append(nutrient.toDictionary())
        }
        recipeDict["nutrients"] = nutrientArray
        
        return recipeDict
    }
    
    func saveRecipe() {
        let recipesRef = db.collection("recipes")
        recipesRef.document(String(self.id)).setData(self.formatToSave(), merge: true)
    }
    
    func saveRecipeIdForUser() {
        let currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        let savedRecipe = ["id" : id, "date" : Date().timeIntervalSince1970.magnitude] as [String : Any]
        currentUserRef.setData(["savedRecipes" : FieldValue.arrayUnion([savedRecipe])], merge: true)
    }
}
