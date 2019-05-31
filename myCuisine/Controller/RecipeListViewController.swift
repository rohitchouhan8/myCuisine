//
//  RecipeListViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/25/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit

class RecipeListViewController: UITableViewController {
    let db = Firestore.firestore() //Firestore database
    var currentUserRef : DocumentReference? //Reference to the current user's collection in Firestore
    let rowHeight = 240
    var recipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        // Do any additional setup after loading the view.
        configureTableView()
        updateNavBar()
        updateTabBar()
    }
    
    func updateTabBar() {
        guard let tabBar = tabBarController?.tabBar else {fatalError()}
        tabBar.unselectedItemTintColor = UIColor(named: "Main Green") ?? .green
    }

    func updateNavBar() {
        guard let navBar = navigationController?.navigationBar else {fatalError()}
        navBar.tintColor = UIColor(named: "Dark Gray") ?? .black
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : navBar.tintColor!]
        
    }
    
    //MARK: Table view methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
        let recipe = recipes[indexPath.row]
        cell.recipeNameLabel.text = recipe.title
        cell.creditLabel.text = recipe.creditText
        cell.numberMinutesLabel.text = String(recipe.readyInMinutes)
        cell.numberIngredientsLabel.text = String(recipe.ingredients.count)
        
        cell.recipeImageView.sd_setImage(with: URL(string: recipe.imageURL))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc2 = DetailRecipeViewController()
        
        // this enables Hero
        vc2.hero.isEnabled = true
        
        // this configures the built in animation
        //    vc2.hero.modalAnimationType = .zoom
        //    vc2.hero.modalAnimationType = .pageIn(direction: .left)
        //    vc2.hero.modalAnimationType = .pull(direction: .left)
        //    vc2.hero.modalAnimationType = .autoReverse(presenting: .pageIn(direction: .left))
        vc2.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .fade)
        
        //        // lastly, present the view controller like normal
        //        present(vc2, animated: true, completion: nil)
        
        performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetailRecipeViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            let recipe = recipes[indexPath.row]
            destinationVC.recipe = recipe
        }
    }
    

    //Configures table view to set the delegate and data source properties. It also sets the row height and the custom recipe cell to use for display.

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
        
        let diets = data["diets"] as! [String]
        
        let servings = data["servings"] as! Int
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
        
        var instructions = [Instruction]()
        for instFirestore in data["instructions"] as! [Any] {
            let instObject = instFirestore as! [String : Any]
            let number = instObject["number"] as! Int
            let step = instObject["step"] as! String
            instructions.append(Instruction(number: number, step: step))
        }
        let recipe = Recipe(id: id, preparationMinutes: preparationMinutes, cookingMinutes: cookingMinutes, readyInMinutes: readyInMinutes, aggregateLikes: aggregateLikes, healthScore: healthScore, servings: servings, sourceURL: sourceURL, imageURL: imageURL, creditText: creditText, title: title, ingredients: ingredients, instructions: instructions, diets: diets, cuisines: cuisines)
        
        return recipe
    }
    
    //Configures table view to set the delegate and data source properties. It also sets the row height and the custom recipe cell to use for display.
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName:"RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "recipeCell")
        tableView.rowHeight = CGFloat(rowHeight)
        tableView.separatorStyle = .none
        
    }


}
