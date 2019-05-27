//
//  RecipeListViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/25/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase

class RecipeListViewController: UIViewController {
    let db = Firestore.firestore() //Firestore database
    var currentUserRef : DocumentReference? //Reference to the current user's collection in Firestore
    let rowHeight = 240
    var recipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        // Do any additional setup after loading the view.
        
    }
    
    //Configures table view to set the delegate and data source properties. It also sets the row height and the custom recipe cell to use for display.
    func configureTableView() {
        
    }
    
    func loadRecipes() {
        
    }


    func getRecipeFromFirestore(data: [String : Any]) -> Recipe {
        
        //        let id = recipeJSON["id"].intValue
        let id = data["id"] as! Int
        //        let preparationMinutes = recipeJSON["preparationMinutes"].intValue
        let preparationMinutes = data["preparationMinutes"] as! Int
        //        let cookingMinutes = recipeJSON["cookingMinutes"].intValue
        let cookingMinutes = data["cookingMinutes"] as! Int
        //        let readyInMinutes = recipeJSON["readyInMinutes"].intValue
        let readyInMinutes = data["readyInMinutes"] as! Int
        //        let aggregateLikes = recipeJSON["aggregateLikes"].intValue
        let aggregateLikes = data["aggregateLikes"] as! Int
        //        let healthScore = recipeJSON["healthScore"].intValue
        let healthScore = data["healthScore"] as! Int
        //        let sourceURL = recipeJSON["sourceUrl"].stringValue
        let sourceURL = data["sourceURL"] as! String
        //        let imageURL = recipeJSON["image"].stringValue
        let imageURL = data["imageURL"] as! String
        //        let creditText = recipeJSON["creditText"].stringValue
        let creditText = data["creditText"] as! String
        //        let title = recipeJSON["title"].stringValue
        let title = data["title"] as! String
        //        let instructions = recipeJSON["instructions"].stringValue
        let instructions = data["instructions"] as! String
        
        let diets = data["diets"] as! [String]
        //        var diets = [String]()
        //        for diet in recipeJSON["diets"].arrayValue {
        //            diets.append(diet.stringValue)
        //        }
        var ingredients = [Ingredient]()
        //        for ingredientJSON in recipeJSON["extendedIngredients"].arrayValue {
        for ingredientFirestore in data["ingredients"] as! [Any] {
            let ingObject = ingredientFirestore as! [String : Any]
            let originalName = ingObject["originalName"] as! String
            let name = ingObject["name"] as! String
            let unit = ingObject["unit"] as! String
            let amount = ingObject["amount"] as! Int
            let id = ingObject["id"] as! Int
            ingredients.append(Ingredient(originalName: originalName, name: name, unit: unit, amount: amount, id: id))
        }
        //            let originalName = ingredientJSON["originalName"].stringValue
        //            let name = ingredientJSON["name"].stringValue
        //            let unit = ingredientJSON["unit"].stringValue
        //            let amount = ingredientJSON["amount"].intValue
        //            let id = ingredientJSON["id"].intValue
        //            ingredients.append(Ingredient(originalName: originalName, name: name, unit: unit, amount: amount, id: id))
        //        }
        //
        //        var cuisines = [String]()
        //        for cuisine in recipeJSON["cuisines"].arrayValue {
        //            cuisines.append(cuisine.stringValue)
        //        }
        let cuisines = data["cuisines"] as! [String]
        
        //
        let recipe = Recipe(id: id, preparationMinutes: preparationMinutes, cookingMinutes: cookingMinutes, readyInMinutes: readyInMinutes, aggregateLikes: aggregateLikes, healthScore: healthScore, sourceURL: sourceURL, imageURL: imageURL, creditText: creditText, title: title, ingredients: ingredients, instructions: instructions, diets: diets, cuisines: cuisines)
        
        return recipe
    }


}
