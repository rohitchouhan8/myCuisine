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
import PromiseKit
import BBBadgeBarButtonItem

class NewRecipesViewController: RecipeListViewController  {

    
    // Base url for searching for recipe
    let recipeSearchURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/searchComplex"
    
    //Base url for getting a recipe
    let getRecipeURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes"
    
    // Base url for getting random recipes
    let randomRecipeURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/random"
    
    //Key and host for headers for API requests
    var host : String?
    var key : String?
    
    //Indicator if we have already loaded the new recipes and we don't need to do it again.
    var justLoadedNewRecipes : Bool = false
    
    //Number of recipes to display
    let numOptions = 7
    
    
    let timeUntilNewRecipes = Double(86400)
    
    //A count of the most preferred cuisines for the user
    var cuisineCount =  [String : Double]()
    
    // A list of the diet restrictions for the user
    var dietLabels = [String]()
    
    // A list of disliked foods for the user
    var dislikedFoods = [String]()
    
    //A list of the intolerable foods for the user
    var intolerableFoods = [String]()
    
    // A count of the most preferred ingredients for the user
    var ingredientCount = [String : Double]()
    
    // Different types of networking requests
    enum requestType {
        case search
        case getRecipe
        case getRandom
    }
    
    let defaults = UserDefaults.standard
    let numCustomLeftKey = "numCustomLeft"
    let numRandomLeftKey = "numRandomLeft"
    
    var userData : [String : Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Establish the firestore document for the user
        currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        // Get the Spoonacular host and key for networking headers
        guard let secrets = NetworkingUtilFunctions.getPlist(withName: "Secrets") else {fatalError()}
        host = secrets["Host"]!
        key = secrets["Key"]!
        
        currentUserRef?.addSnapshotListener({ (snapshot, error) in
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            self.userData = data
            print("from snapshot listener")
            //            self.loadRecipes(override: false)
            self.updateBadges()
        })
        
        let image = UIImage(named: "Whisk")
        let whiskButton = UIButton(type: .custom)
        whiskButton.setImage(image, for: .normal)
        whiskButton.addTarget(self, action: #selector(customRecipesButtonPressed(_:)), for: .touchUpInside)
        let customRecipeButton = createBadge(with: whiskButton, for: numCustomLeftKey)
        
        let imageRandom = UIImage(named: "random")
        let randomButton = UIButton(type: .custom)
        randomButton.setImage(imageRandom, for: .normal)
        randomButton.addTarget(self, action: #selector(randomRecipeButtonPressed(_:)), for: .touchUpInside)
        
        let randomRecipeButton = createBadge(with: randomButton, for: numRandomLeftKey)
        
        let refreshButton = UIBarButtonItem(image: UIImage(named: "reload"), style: .plain, target: self, action: #selector(loadRecipes(override:)))
        self.navigationItem.rightBarButtonItems = [ customRecipeButton, randomRecipeButton, refreshButton ] as? [UIBarButtonItem]

        
//        currentUserRef?.setData([numCustomLeftKey : 1], merge: true)
//        currentUserRef?.setData([numRandomLeftKey : 1], merge: true)
        loadRecipes(override: false)
    }
    
    func setupUserData() {
        currentUserRef?.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
                    self.userData = data
                    self.updateBadges()
                }
            }
        }
    }
    
    func updateBadges() {
        print("Updating Badges")
        if let item = self.navigationItem.rightBarButtonItems?[0] as? BBBadgeBarButtonItem {
            if let change = userData?[numCustomLeftKey] as? Int {
                item.badgeValue = String(change)
            }
        }
        if let item = self.navigationItem.rightBarButtonItems?[1] as? BBBadgeBarButtonItem {
            if let change = userData?[numRandomLeftKey] as? Int {
                item.badgeValue = String(change)
            }
        }


    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == numCustomLeftKey {
//            if let item = self.navigationItem.rightBarButtonItems?[0] as? BBBadgeBarButtonItem {
//                if let change = defaults.object(forKey: numCustomLeftKey) as? Int {
//                    item.badgeValue = String(change)
//                }
//            }
//        } else {
//            if let item = self.navigationItem.rightBarButtonItems?[1] as? BBBadgeBarButtonItem {
//                if let change = defaults.object(forKey: numRandomLeftKey) as? Int {
//                    item.badgeValue = String(change)
//                }
//            }
//        }
//    }
    
    func createBadge(with button: UIButton, for key: String) -> BBBadgeBarButtonItem? {

        let badgeItem = BBBadgeBarButtonItem.init(customUIButton: button)
        badgeItem?.badgeOriginX = 15
        badgeItem?.badgeOriginY = -15
        badgeItem?.shouldAnimateBadge = true
        badgeItem?.shouldHideBadgeAtZero = true
        let value = userData?[key] as? Int ?? 0
        badgeItem?.badgeValue = String(value)
        return badgeItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadRecipes(override: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Loading recipes now")
//        loadRecipes(override: false)
//        tableView.reloadData()
        print("CURRENT USER: \(Auth.auth().currentUser!.uid)")
        
        print("Just loaded new recipes \(justLoadedNewRecipes)")
    }
    
    func refreshRecipeList() {
        loadRecipes(override: false)
    }
    
    
    /**
     Get new custom recipes and display them
     - Parameters: sender- the button pressed
     - Returns: None
     */
    @objc func customRecipesButtonPressed(_ sender: Any) {
        
        if let value = userData?[numCustomLeftKey] as? Int  {
            if value > 0 {
                currentUserRef?.setData([numCustomLeftKey : value - 1], merge: true)
                loadRecipes(override: true)
            } else {
                print("PAY UP")
            }
        } else {
            currentUserRef?.setData([numRandomLeftKey : 0], merge: true)
        }
        
    }
    
    /**
     Get recipes recipes and display them
     - Parameters: sender- the button pressed
     - Returns: None
     */
    @objc func randomRecipeButtonPressed(_ sender: Any) {
        if let value = userData?[numRandomLeftKey] as? Int  {
            if value > 0 {
                currentUserRef?.setData([numRandomLeftKey : value - 1], merge: true)
                getRandomRecipes()
            } else {
                print("PAY UP")
            }
        } else {
            currentUserRef?.setData([numRandomLeftKey : 0], merge: true)
        }
        
    }
    
    /**
     Loads recipes for the user. If new custom recipes have not been loaded in 24 hours, then new custom recipes will be loaded. Otherwise, the current recipes will be loaded.
     - Parameters: override- if true, immediately load new recipes regardless of the timestamp
     - Returns: None
     */
    @objc func loadRecipes(override: Bool) {
        recipes = [Recipe]()

        if let data = userData {
            let recipesLastChanged = data["recipesLastChanged"] as? Double ?? 0.0
            if (Date().timeIntervalSince1970.magnitude - recipesLastChanged > self.timeUntilNewRecipes) {
                print("Loading new recipes...")
                self.getAndUpdateNumberSpins(for: self.numCustomLeftKey)
                self.getAndUpdateNumberSpins(for: self.numRandomLeftKey)
                self.loadNewRecipes(with: data)
                self.justLoadedNewRecipes = true
            } else if override {
                self.loadNewRecipes(with: data)
                self.justLoadedNewRecipes = true
            } else {
                print("Loading current recipes...")
                self.loadCurrentRecipes(with: data)
            }
        } else {
            print("User document does not exist")
        }
        
    }
    
    func getAndUpdateNumberSpins(for key: String) {
        if let data = userData {
            if let numSpins = data[key] as? Int {
                if numSpins < 5 {
//                    currentUserRef?.setValue(numSpins + 1, forKey: key)
                    currentUserRef?.setData([key : numSpins + 1], merge: true)
                }
            } else {
                currentUserRef?.setData([key : 1], merge: true)
            }
        }
//        if let numberOfCustomSpins = defaults.object(forKey: key) as? Int {
//            if numberOfCustomSpins < 5 {
//                defaults.set(numberOfCustomSpins + 1, forKey: key)
//            }
//        } else {
//            defaults.set(1, forKey: key)
//        }
        
    }
    

    

    /**
     Loads new custom recipes.
     - Parameters: userData - all of the information about the user's account activity
     - Returns: None
     */
    func loadNewRecipes(with userData: [String : Any]) {
        // Get user preferences
        cuisineCount = (userData["cuisineCount"] as! [String : Double])
        dietLabels = (userData["selectedDL"] as! [String])
        dislikedFoods = (userData["disliked"] as! [String])
        intolerableFoods = (userData["intolerable"] as! [String])
        ingredientCount = (userData["ingredientCount"] as? [String : Double]) ?? [String : Double]()
        self.makeSearchRequest(cuisineCount: cuisineCount, dietLables: dietLabels, dislikedFoods: dislikedFoods, intolerableFoods: intolerableFoods, ingredientCount: ingredientCount)
 
    }
    
    /**
     Loads most recently viewed recipes.
     - Parameters: userData - all of the information about the user's account activity
     - Returns: None
     */
    func loadCurrentRecipes(with userData: [String : Any]) {
        let recipesCollectionRef = db.collection("recipes")
        let recipeIdArray = userData["currentRecipes"] as! [Int]
        // Load every recipe by accessing it from the recipe document
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
                    print("Recipe document does not exist")
                }
            }
        }
    }
    
    //MARK: Networking requests to Spoonacular
    
    /**
     Use Alamofire to make a networking request to Spoonacular
     - Parameters:
        url - address of the networking endpoint
        headers - host and key of the request
        params - any parameters for the query
     - Returns: None
     */
    func makeRequest(url: String, headers: [String : String], params : [String : Any]?, type: requestType) {
        
        let encoding = URLEncoding(arrayEncoding: .noBrackets)
        
        
        let request = Alamofire.request(url, method: .get, parameters: params, encoding: encoding, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got recipe data")
                let recipeJSON : JSON = JSON(response.result.value!)
                // choose where to send the data to process depending on the request type
                switch type {
                case .search:
                    self.handleSearchRequest(for: recipeJSON)
                    break
                case .getRecipe:
                    print("recipe request \(String(describing: response.request))")
//                    print("recipe info \(recipeJSON)")
                    NetworkingUtilFunctions.handleGetRecipeRequest(for: recipeJSON).done({ (recipe) in
                        self.recipes.append(recipe)
                        print("Recipe count \(self.recipes.count)")
                        if self.recipes.count == self.numOptions {
                            NetworkingUtilFunctions.saveCurrentRecipes(recipes: self.recipes)
                            self.tableView.reloadData()
                        }
                        
                    })
                    break
                case .getRandom:
                    self.handleGetRandomRequest(for: recipeJSON)
                }
                
            } else {
                print("Error \(response.result.error!)")
            }
        }

    }
    
    /**
     Create all of the components for the recipe search.
     - Parameters:
     cuisineCount - A count of the most preferred cuisines for the user
     dietLabels - A list of the diet restrictions for the user
     dislikedFoods - A list of disliked foods for the user
     intolerableFoods - A list of the intolerable foods for the user
     ingredientCount - A count of the most preferred ingredients for the user
     - Returns: None
     */
    func makeSearchRequest(cuisineCount: [String: Double], dietLables : [String], dislikedFoods : [String], intolerableFoods : [String], ingredientCount: [String : Double]) {
        let cuisine = getPrefferedItem(count: cuisineCount, numItems: 2)
        let ingredients = getPrefferedItem(count: ingredientCount, numItems: 1)
        let params = [
                      "diet" : reformatString(array: dietLables),
                      "cuisine" : reformatString(array: cuisine),
                      "includeIngredients" : reformatString(array: ingredients),
                      "excludeIngredients" : reformatString(array: dislikedFoods),
                      "intolerances" : reformatString(array: intolerableFoods),
                      "number" : numOptions,
                      "offset" : 0,
                      "type" : "main course"] as [String : Any]
        
        let headers = ["X-RapidAPI-Host" : host!, "X-RapidAPI-Key" : key!]
        makeRequest(url: recipeSearchURL, headers: headers, params: params, type: .search)
    }
    
    /**
     Do a weighted selection and return a list of the selected items.
     - Parameters:
        count - a dictionary mapping the item strings to a double that marks how much it should be weighted
        numItems - number of weighted selections to be made
     - Returns: an array of these selected items.
     */
    func getPrefferedItem(count: [String : Double], numItems : Int) -> [String] {
        if count.isEmpty {
            return [String]()
        }
        let sum = Double(Array(count.values).reduce(0, +))
        var cuisineProbabilities = [String : Double]()
        for (cui, count) in count {
            cuisineProbabilities[cui] = Double(count) / sum
        }
        
        
        var resultArray = [String]()
        for _ in 0..<numItems {
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
        print("Preferred item: \(resultArray)")
        return resultArray
        
    }
    
    /**
     Joins list of strings together
     - Parameters: an array of strings
     - Returns: A string of the list joined by commas
     */
    func reformatString(array : [String]) -> String {
        return array.joined(separator: ", ")
    }
    
    /**
     Parses the data and gets each of the recipes to load.
     - Parameters: recipeJSON - json of the searched recipe JSON
     - Returns: None
     */
    func handleSearchRequest(for recipeJSON : JSON) {
        recipes = [Recipe]()
        if (recipeJSON["totalResults"].intValue < numOptions) {
            print("Not enough results, getting random recipes")
            getRandomRecipes()
            return
        }
        for i in 0..<numOptions {
            let recipeID = recipeJSON["results"][i]["id"].intValue
            let headers = ["X-RapidAPI-Host" : host!, "X-RapidAPI-Key" : key!]
            let params = ["includeNutrition" : "true"]
            let getURL = getRecipeURL + "/\(recipeID)/information"
            
            makeRequest(url: getURL, headers: headers, params: params, type: .getRecipe)
        }
        
    }
    

    /**
     Makes the request for random recipes.
     - Parameters: None
     - Returns: None
     */
    func getRandomRecipes() {
        print("loading random recipes")
        let headers = ["X-RapidAPI-Host" : host!, "X-RapidAPI-Key" : key!]
        let params = ["number" : numOptions,
                      "tags" : "main course," + reformatString(array: dietLabels)] as [String : Any]
        makeRequest(url: randomRecipeURL, headers: headers, params: params, type: .getRandom)
        return
    }
    
    /**
     Parses the data and gets each of the recipes to load.
     - Parameters: recipeJSON - json of the searched recipe JSON
     - Returns: None
     */
    func handleGetRandomRequest(for recipeJSON : JSON) {
        recipes = [Recipe]()
        print("recipe Nutrition \(recipeJSON["nutrition"].dictionaryValue)")
        for i in 0..<numOptions {
            let recipe = recipeJSON["recipes"][i]
            NetworkingUtilFunctions.handleGetRecipeRequest(for: recipe).done { (rec) in
                self.recipes.append(rec)
                if self.recipes.count == self.numOptions {
                    NetworkingUtilFunctions.saveCurrentRecipes(recipes: self.recipes)
                }
                self.tableView.reloadData()
            }
//            print("recipe list count = \(recipes.count)")
        }
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let data = userData {
            let vc = segue.destination as! DetailRecipeViewController
            vc.userPreferences = data
        }
            

    }
    

    

}




