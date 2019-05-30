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
import Hero
import DGElasticPullToRefresh

class NewRecipesViewController: RecipeListViewController  {

    
    // Base url for searching for recipe
    let recipeSearchURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/searchComplex"
    
    //Base url for getting a recipe
    let getRecipeURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes"
    
    //Key and host for headers for API requests
    var host : String?
    var key : String?
    
    var justLoadedNewRecipes : Bool = false
    
    //Number of recipes to display
    let numOptions = 7
    
    let timeUntilNextRefresh = Double(86400)
    
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
        
        print("CURRENT USER: \(Auth.auth().currentUser!.uid)")
        loadRecipes(override: false)
        print("Just loaded new recipes \(justLoadedNewRecipes)")
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: Selector(("refreshButtonPressed")))
        navigationController?.navigationItem.rightBarButtonItem = refreshButton
        
    }
    
    func refreshButtonPressed() {
        
    }
    
//    override func configureTableView() {
//        super.configureTableView()
//        // Initialize tableView
//        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
//        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
//        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
//            // Add your logic here
//            self?.loadRecipes(override: true)
//            // Do not forget to call dg_stopLoading() at the end
//            self?.tableView.dg_stopLoading()
//            }, loadingView: loadingView)
//        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
//        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
//    }
    
    
    func loadRecipes(override: Bool) {
        recipes = [Recipe]()
        
        currentUserRef?.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
                    let recipesLastChanged = data["recipesLastChanged"] as? Double ?? 0.0
                    if (Date().timeIntervalSince1970.magnitude - recipesLastChanged > self.timeUntilNextRefresh) || override {
                        print("Loading new recipes...")
                        self.loadNewRecipes(with: data)
                        self.justLoadedNewRecipes = true
                    } else {
                        print("Loading current recipes...")
                        self.loadCurrentRecipes(with: data)
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
        
    }
    

    

    
    func loadNewRecipes(with userData: [String : Any]) {
        let cuisineCount = (userData["cuisineCount"] as! [String : Int])
        let dietLabels = (userData["selectedDL"] as! [String])
        let dislikedFoods = (userData["disliked"] as! [String])
        let intolerableFoods = (userData["intolerable"] as! [String])
        self.makeSearchRequest(cuisineCount: cuisineCount, dietLables: dietLabels, dislikedFoods: dislikedFoods, intolerableFoods: intolerableFoods)
 
    }
    
    func loadCurrentRecipes(with userData: [String : Any]) {
        let recipesCollectionRef = db.collection("recipes")
        let recipeIdArray = userData["currentRecipes"] as! [Int]
        for recipeId in recipeIdArray {
            let recipeDocument = recipesCollectionRef.document(String(recipeId))
            recipeDocument.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data() {
                        let recipe = self.getRecipeFromFirestore(data: data)
                        self.recipes.append(recipe)
                        self.tableView.reloadData()
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }


    
    
    
    //MARK: Networking requests to Spoonacular
    func makeRequest(url: String, headers: [String : String], params : [String : Any]?, type: requestType) {
        
        let encoding = URLEncoding(arrayEncoding: .noBrackets)
        
        
        Alamofire.request(url, method: .get, parameters: params, encoding: encoding, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got recipe data")
                let recipeJSON : JSON = JSON(response.result.value!)
//                print(recipeJSON)
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
    
    func makeSearchRequest(cuisineCount: [String: Int], dietLables : [String], dislikedFoods : [String], intolerableFoods : [String]) {
        let cuisine = getPreferredCuisine(cuisineCount: cuisineCount, numCuisines: 3)
        let params = ["limitLicense" : true,
                      "diet" : reformatString(array: dietLables),
                      "cuisine" : reformatString(array: cuisine),
                      "excludeIngredients" : reformatString(array: dislikedFoods),
                      "intolerances" : reformatString(array: intolerableFoods),
                      "number" : numOptions,
                      "offset" : Int(arc4random_uniform(30)),
                      "type" : "main course"] as [String : Any]
        let headers = ["X-RapidAPI-Host" : host!, "X-RapidAPI-Key" : key!]
        makeRequest(url: recipeSearchURL, headers: headers, params: params, type: .search)
    }
    
    func getPreferredCuisine(cuisineCount: [String : Int], numCuisines : Int) -> [String] {
        let sum = Double(Array(cuisineCount.values).reduce(0, +))
        var cuisineProbabilities = [String : Double]()
        for (cui, count) in cuisineCount {
            cuisineProbabilities[cui] = Double(count) / sum
        }
        
        
        var resultArray = [String]()
        for _ in 0..<numCuisines {
            let rnd = Double.random(in: 0.0..<1.0)
            var accum = 0.0
            for cui in cuisineProbabilities {
                accum += cui.value
                if (rnd < accum) {
                    resultArray.append(cui.key)
                    cuisineProbabilities.removeValue(forKey: cui.key)
                    break
                }
            }
        }
        print("Preferred cuisines: \(resultArray)")
        return resultArray
        
    }
    
    func reformatString(array : [String]) -> String {
        return array.joined(separator: ", ")
    }
    
    func handleSearchRequest(for recipeJSON : JSON) {
        for i in 0..<numOptions {
            let recipeID = recipeJSON["results"][i]["id"].intValue
            let headers = ["X-RapidAPI-Host" : host!, "X-RapidAPI-Key" : key!]
            let getURL = getRecipeURL + "/\(recipeID)/information"
            makeRequest(url: getURL, headers: headers, params: nil, type: .getRecipe)
            print("recipe list count = \(recipes.count)")
        }
        
    }

    
    func handleGetRecipeRequest(for recipeJSON: JSON) {
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
            let amount = ingredientJSON["amount"].intValue
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
        
        
        let recipe = Recipe(id: id, preparationMinutes: preparationMinutes, cookingMinutes: cookingMinutes, readyInMinutes: readyInMinutes, aggregateLikes: aggregateLikes, healthScore: healthScore, servings: servings, sourceURL: sourceURL, imageURL: imageURL, creditText: creditText, title: title, ingredients: ingredients, instructions: instructions, diets: diets, cuisines: cuisines)
        
        recipes.append(recipe)
        if recipes.count == numOptions {
            saveCurrentRecipes()
        }
        recipe.saveRecipe()
//        print("SAVED RECIPE: \(recipe)")
        tableView.reloadData()
    }
    
    func getPlist(withName name: String) -> [String : String]? {
        if  let path = Bundle.main.path(forResource: name, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path)
        {
            return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String : String]
        }
        
        return nil
    }

    

//    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
//        //TODO: Log out the user and send them back to WelcomeViewController
//        do {
//            try Auth.auth().signOut()
//            self.dismiss(animated: true, completion: {})
//            self.navigationController?.popToRootViewController(animated: true)
//
//        } catch {
//            print("Error signing out")
//        }
//    }
//
//    @IBAction func refreshPressed(_ sender: UIButton) {
//        recipes = [Recipe]()
//        guard let userRef = currentUserRef else {fatalError()}
//        userRef.getDocument { (document, error) in
//            print("started")
//            if let document = document, document.exists {
//                if let data = document.data() {
//                    self.loadNewRecipes(with: data)
//                }
//            }
//        }
//
//    }
    
    
    
    //MARK: Firestore methods
    func saveCurrentRecipes() {
        guard let userRef = currentUserRef else {fatalError()}
        var currentRecipeIds = [Int]()
        for recipe in recipes {
            currentRecipeIds.append(recipe.id)
        }
        userRef.setData(["currentRecipes" : currentRecipeIds], merge: true)
        userRef.setData(["recipesLastChanged" : Date().timeIntervalSince1970.magnitude], merge: true)
        
    }
    

}




