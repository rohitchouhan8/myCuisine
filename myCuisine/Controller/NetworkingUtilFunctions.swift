//
//  NetworkingUtilFunctions.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 6/23/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit
import Firebase
import Alamofire

class NetworkingUtilFunctions {
    /**
     Parses the data and saves the recipe.
     - Parameters: recipeJSON - json of the searched recipe JSON
     - Returns: None
     */
    static func handleGetRecipeRequest(for recipeJSON: JSON) -> Promise<Recipe> {
        return Promise<Recipe> { seal in
            let id = recipeJSON["id"].intValue
            let preparationMinutes = recipeJSON["preparationMinutes"].intValue
            let cookingMinutes = recipeJSON["cookingMinutes"].intValue
            let readyInMinutes = recipeJSON["readyInMinutes"].intValue
            let aggregateLikes = recipeJSON["aggregateLikes"].intValue
            let servings = recipeJSON["servings"].intValue
            let healthScore = recipeJSON["healthScore"].intValue
            let sourceURL = recipeJSON["sourceUrl"].stringValue
            let imageURL = recipeJSON["image"].stringValue
            let creditText = recipeJSON["creditsText"].stringValue
            let title = recipeJSON["title"].stringValue
            //        let instructions = recipeJSON["instructions"].stringValue
            var diets = [String]()
            for diet in recipeJSON["diets"].arrayValue {
                diets.append(diet.stringValue)
            }
            var ingredients = [Ingredient]()
            for ingredientJSON in recipeJSON["extendedIngredients"].arrayValue {
                let originalName = ingredientJSON["originalName"].stringValue
                let name = ingredientJSON["name"].stringValue
                let unit = ingredientJSON["unit"].stringValue
                let amount = ingredientJSON["amount"].doubleValue
                let id = ingredientJSON["id"].intValue
                ingredients.append(Ingredient(originalName: originalName, name: name, unit: unit, amount: amount, id: id))
            }
            
            var cuisines = [String]()
            for cuisine in recipeJSON["cuisines"].arrayValue {
                cuisines.append(cuisine.stringValue)
            }
            
            var instructions = [Instruction]()
            for instJSON in recipeJSON["analyzedInstructions"][0]["steps"].arrayValue {
                let number = instJSON["number"].intValue
                let step = instJSON["step"].stringValue
                instructions.append(Instruction(number: number, step: step))
            }
            
            var nutrients = [Nutrient]()
            if let nutrientsJSON = recipeJSON["nutrition"]["nutrients"].array {
                for nutJSON in nutrientsJSON {
                    let title = nutJSON["title"].stringValue
                    let amount = nutJSON["amount"].intValue
                    let unit = nutJSON["unit"].stringValue
                    let percentOfDailyNeeds = nutJSON["percentOfDailyNeeds"].doubleValue
                    nutrients.append(Nutrient(name: title, amount: amount, unit: unit, percentOfDailyNeeds: percentOfDailyNeeds))
                }
                let recipe = Recipe(id: id, preparationMinutes: preparationMinutes, cookingMinutes: cookingMinutes, readyInMinutes: readyInMinutes, aggregateLikes: aggregateLikes, healthScore: healthScore, servings: servings, sourceURL: sourceURL, imageURL: imageURL, creditText: creditText, title: title, ingredients: ingredients, instructions: instructions, diets: diets, cuisines: cuisines, nutrients: nutrients)
                
                //            recipes.append(recipe)
                //            if recipes.count == numOptions {
                //                saveCurrentRecipes(recipes: recipes)
                //            }
                recipe.saveRecipe()
                seal.fulfill(recipe)
                //        print("SAVED RECIPE: \(recipe)")
            } else {
                getNutrition(for: id).done { (nutrientsFromPromise) in
                    print("Got nutrition")
                    nutrients = nutrientsFromPromise
                    let recipe = Recipe(id: id, preparationMinutes: preparationMinutes, cookingMinutes: cookingMinutes, readyInMinutes: readyInMinutes, aggregateLikes: aggregateLikes, healthScore: healthScore, servings: servings, sourceURL: sourceURL, imageURL: imageURL, creditText: creditText, title: title, ingredients: ingredients, instructions: instructions, diets: diets, cuisines: cuisines, nutrients: nutrients)
                    
                    //                self.recipes.append(recipe)
                    //                if self.recipes.count == self.numOptions {
                    //                    self.saveCurrentRecipes()
                    //                }
                    recipe.saveRecipe()
                    seal.fulfill(recipe)
                    //        print("SAVED RECIPE: \(recipe)")
                    
                }
            }
        }
    }
    
    static func getNutrition(for recipeId: Int) -> Promise<[Nutrient]> {
        print("Getting nutrition")
        let url = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/\(recipeId)/nutritionWidget.json"
        var secrets : [String : String]
        // Get the Spoonacular host and key for networking headers
        if  let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path)
        {
            secrets = (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as! [String : String]
        } else {
            fatalError()
        }

        let host = secrets["Host"]!
        let key = secrets["Key"]!
        let headers = ["X-RapidAPI-Host" : host, "X-RapidAPI-Key" : key]
        return Promise<[Nutrient]> { seal in
            Alamofire.request(url, method: .get, headers: headers).responseJSON { (response) in
                if response.result.isSuccess {
                    var nutrients = [Nutrient]()
                    let json = JSON(response.result.value!)
                    print("json \(json)")
                    for bad in json["bad"].arrayValue {
                        let title = bad["title"].stringValue
                        let amount = bad["amount"].intValue
                        let unit = bad["unit"].stringValue
                        let percentOfDailyNeeds = bad["percentOfDailyNeeds"].doubleValue
                        nutrients.append(Nutrient(name: title, amount: amount, unit: unit, percentOfDailyNeeds: percentOfDailyNeeds))
                    }
                    for good in json["good"].arrayValue {
                        let title = good["title"].stringValue
                        let amount = good["amount"].intValue
                        let unit = good["unit"].stringValue
                        let percentOfDailyNeeds = good["percentOfDailyNeeds"].doubleValue
                        nutrients.append(Nutrient(name: title, amount: amount, unit: unit, percentOfDailyNeeds: percentOfDailyNeeds))
                    }
                    
                    seal.fulfill(nutrients)
                    
                } else {
                    print("Error \(response.result.error!)")
                    seal.reject(response.result.error!)
                }
            }
        }
    }
    
    

    
    //MARK: Firestore methods
    /**
     Save the current recipes to the user's firestore document
     - Parameters: none
     - Returns: None
     */
    static func saveCurrentRecipes(recipes: [Recipe]) {
        let db = Firestore.firestore()
        let currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        var currentRecipeIds = [Int]()
        for recipe in recipes {
            currentRecipeIds.append(recipe.id)
        }
        currentUserRef.setData(["currentRecipes" : currentRecipeIds], merge: true)
        currentUserRef.setData(["recipesLastChanged" : Date().timeIntervalSince1970.magnitude], merge: true)
    }
    
    /**
     Reads the secret plist
     - Parameters: name - the name of the plist
     - Returns: the plist optional
     */
    static func getPlist(withName name: String) -> [String : String]? {
        if  let path = Bundle.main.path(forResource: name, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path)
        {
            return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String : String]
        }
        
        return nil
    }
    
}


