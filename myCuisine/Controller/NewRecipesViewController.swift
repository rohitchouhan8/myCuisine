//
//  FirstViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/15/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import SearchTextField
import SDWebImage

class NewRecipesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let db = Firestore.firestore()
    var currentUserRef : DocumentReference?
    let recipeSearchURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/searchComplex"
    let getRecipeURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes"
    var host : String?
    var key : String?
    var recipes = [Recipe]()
    
    @IBOutlet weak var recipeTableView: UITableView!
    enum requestType {
        case search
        case getRecipe
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
//        loadUserPreferences()
        guard let secrets = getPlist(withName: "Secrets") else {fatalError()}
        host = secrets["Host"]!
        key = secrets["Key"]!
        makeSearchRequest()
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
        recipeTableView.register(UINib(nibName:"RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "recipeCell")
        recipeTableView.rowHeight = 120
        
        
    }
    
//    func loadUserPreferences() {
//        guard let userRef = currentUserRef else {fatalError()}
//        userRef.getDocument { (document, error) in
//            print("started")
//            if let document = document, document.exists {
//                if let data = document.data() {
//                    let healthLabels = (data["selectedHL"] as! [String])
//                    let dietLabels = (data["selectedDL"] as! [String])
//                    let dislikedFoods = (data["disliked foods"] as! [String])
//                    let likedFoods = (data["liked foods"] as! [String])
////                    self.makeRequest(for: dislikedFoods, for: dietLabels, for: healthLabels, for: likedFoods)
//                }
//
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }
    
    //MARK: Networking requests to Spoonacular
    func makeRequest(url: String, headers: [String : String], params : [String : Any]?, type: requestType) {
        
        let encoding = URLEncoding(arrayEncoding: .noBrackets)
        
        
        Alamofire.request(url, method: .get, parameters: params, encoding: encoding, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got recipe data")
                let recipeJSON : JSON = JSON(response.result.value!)
                print(recipeJSON)
                switch type {
                case .search:
                    self.handleSearchRequest(for: recipeJSON)
                    break
                case .getRecipe:
                    self.handleGetRecipeRequest(for: recipeJSON)
                    break
                }
                
            } else {
                print("Error \(response.result.error!)")
            }
        }
    }
    
    func makeSearchRequest() {
        
        let params = ["limitLicense" : true,
                      "query" : "salad",
                      "diet" : "vegetarian",
                      "excludeIngredients" : "coconut",
                      "intolerances" : "egg, gluten",
                      "number" : 10,
                      "offset" : 0,
                      "type" : "main course"] as [String : Any]
        let headers = ["X-RapidAPI-Host" : host!, "X-RapidAPI-Key" : key!]
        makeRequest(url: recipeSearchURL, headers: headers, params: params, type: .search)
    }
    
    func handleSearchRequest(for recipeJSON : JSON) {
        let recipeID = recipeJSON["results"][0]["id"].intValue
        let headers = ["X-RapidAPI-Host" : host!, "X-RapidAPI-Key" : key!]
        let getURL = getRecipeURL + "/\(recipeID)/information"
        makeRequest(url: getURL, headers: headers, params: nil, type: .getRecipe)
        
    }

    
    func handleGetRecipeRequest(for recipeJSON: JSON) {
        let id = recipeJSON["id"].intValue
        let preparationMinutes = recipeJSON["preparationMinutes"].intValue
        let cookingMinutes = recipeJSON["cookingMinutes"].intValue
        let readyInMinutes = recipeJSON["readyInMinutes"].intValue
        let aggregateLikes = recipeJSON["aggregateLikes"].intValue
        let healthScore = recipeJSON["healthScore"].intValue
        let sourceURL = recipeJSON["sourceUrl"].stringValue
        let imageURL = recipeJSON["image"].stringValue
        let creditText = recipeJSON["creditText"].stringValue
        let title = recipeJSON["title"].stringValue
        let instructions = recipeJSON["instructions"].stringValue
        var diets = [String]()
        for diet in recipeJSON["diets"].arrayValue {
            diets.append(diet.stringValue)
        }
        var ingredients = [Ingredient]()
        for ingredientJSON in recipeJSON["extendedIngredients"].arrayValue {
            let name = ingredientJSON["originalName"].stringValue
            let unit = ingredientJSON["unit"].stringValue
            let amount = ingredientJSON["amount"].intValue
            let id = ingredientJSON["id"].intValue
            ingredients.append(Ingredient(originalName: name, unit: unit, amount: amount, id: id))
        }
        
        let recipe = Recipe(id: id, preparationMinutes: preparationMinutes, cookingMinutes: cookingMinutes, readyInMinutes: readyInMinutes, aggregateLikes: aggregateLikes, healthScore: healthScore, sourceURL: sourceURL, imageURL: imageURL, creditText: creditText, title: title, ingredients: ingredients, instructions: instructions, diets: diets)
        recipes.append(recipe)
        print("SAVED RECIPE: \(recipe)")
        recipeTableView.reloadData()
    }
    
    func getPlist(withName name: String) -> [String : String]? {
        if  let path = Bundle.main.path(forResource: name, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path)
        {
            return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String : String]
        }
        
        return nil
    }


    @IBAction func logoutPressed(_ sender: Any) {
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch {
            print("Error signing out")
        }
        
    }
    
    //MARK: Table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recipeTableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
        let recipe = recipes[indexPath.row]
        cell.recipeNameLabel.text = recipe.title
        cell.creditLabel.text = recipe.creditText
        cell.numberMinutesLabel.text = String(recipe.readyInMinutes)
        cell.numberIngredientsLabel.text = String(recipe.ingredients.count)
        
        cell.recipeImageView.sd_setImage(with: URL(string: recipe.imageURL))
        
        return cell
    }
}



