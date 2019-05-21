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

class NewRecipesViewController: UIViewController {
    let db = Firestore.firestore()
    var currentUserRef : DocumentReference?
    let recipeSearchURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/search"
    enum requestType {
        case search
        case getRecipe
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
//        loadUserPreferences()
        
    }
    
    func loadUserPreferences() {
        guard let userRef = currentUserRef else {fatalError()}
        userRef.getDocument { (document, error) in
            print("started")
            if let document = document, document.exists {
                if let data = document.data() {
                    let healthLabels = (data["selectedHL"] as! [String])
                    let dietLabels = (data["selectedDL"] as! [String])
                    let dislikedFoods = (data["disliked foods"] as! [String])
                    let likedFoods = (data["liked foods"] as! [String])
//                    self.makeRequest(for: dislikedFoods, for: dietLabels, for: healthLabels, for: likedFoods)
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func makeRequest(headers: [String : String], params : [String : Any], type: requestType) {
        
        let encoding = URLEncoding(arrayEncoding: .noBrackets)
        
        
        Alamofire.request(recipeSearchURL, method: .get, parameters: params, encoding: encoding, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got recipe data")
                let recipeJSON : JSON = JSON(response.result.value!)
                print(recipeJSON)
                switch type {
                case .search:
                    self.handleSearchRequest()
                    break
                case .getRecipe:
                    self.handleGetRecipeRequest()
                    break
                }
                
            } else {
                print("Error \(response.result.error!)")
            }
        }
    }
    
    func makeSearchRequest() {
        guard let secrets = getPlist(withName: "Secrets") else {fatalError()}
        let host = secrets["Host"]!
        let key = secrets["Key"]!
        let params = ["query" : "salad",
                      "diet" : "vegetarian",
                      "excludeIngredients" : "coconut",
                      "intolerances" : "egg, gluten",
                      "number" : 10,
                      "offset" : 0,
                      "type" : "main course"] as [String : Any]
        let headers = ["X-RapidAPI-Host" : host, "X-RapidAPI-Key" : key]
        makeRequest(headers: headers, params: params, type: .search)
    }
    
    func handleSearchRequest() {
        
    }
    
    func makeGetRecipeRequest() {
        
    }
    
    func handleGetRecipeRequest() {
        
    }
    
    func getPlist(withName name: String) -> [String : String]? {
        if  let path = Bundle.main.path(forResource: name, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path)
        {
            return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String : String]
        }
        
        return nil
    }



}

