//
//  FoodsSelectorViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/17/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase
import SearchTextField
import Alamofire
import SwiftyJSON

class FoodSelectorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    let foodAutoCompleteURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/food/ingredients/autocomplete"
    
    var selectedFoods = [String]()
    

    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var selectedFoodsTableView: UICollectionView!
    @IBOutlet weak var foodsTableView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    let db = Firestore.firestore()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodsTableView.delegate = self
        foodsTableView.dataSource = self
        foodsTableView.register(UINib(nibName:"CustomSetupItemCell", bundle: nil) , forCellWithReuseIdentifier: "setupItemCell")
        addButton.layer.cornerRadius = 8
        nextButton.layer.cornerRadius = 16
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Foods",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = foodsTableView.dequeueReusableCell(withReuseIdentifier: "setupItemCell", for: indexPath) as! CustomSetupItemCell
        cell.name.text = selectedFoods[indexPath.row]
        cell.image.backgroundColor = UIColor(red:0.90, green:0.69, blue:0.18, alpha: 0.9)
        cell.layer.cornerRadius = 8
        return cell
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("add button presed")
        if let searchText = searchTextField.text {
            if !searchText.isEmpty {
                selectedFoods.append(searchText)
                foodsTableView.reloadData()
                print("appended")
            } else {
                print("did not append because is empty")
            }
        } else {
            print("could not find searchText")
        }
        searchTextField.endEditing(true)
        searchTextField.filterStrings([String]())
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if nextButton.title(for: .normal) == "Next" {
            titleLabel.text = "Intolerable Foods"
            nextButton.setTitle("Submit", for: .normal)
            save(key: "disliked", data: selectedFoods)
            selectedFoods = [String]()
            foodsTableView.reloadData()
        } else {
            save(key: "intolerable", data: selectedFoods)
            performSegue(withIdentifier: "goToMain", sender: self)
        }
        
    }
    
    func save(key: String, data: [String]) {
        let currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        currentUserRef.setData([key: data], merge: true) { (error) in
            if let err = error {
                print("Error writing document: \(err)")
            } else {
                print("Document for \(key) successfully written!")
            }
        }
    }
    
    
    @IBAction func searchEditingChanged(_ sender: SearchTextField) {
        if sender.text?.count ?? 0 >= 3 {
            getSuggestions(for: searchTextField.text!)
        }
    }
    
    func getSuggestions(for substring: String) {
        guard let secrets = getPlist(withName: "Secrets") else {fatalError()}
        let host = secrets["Host"]!
        let key = secrets["Key"]!
        let params = ["query" : substring, "number" : 10] as [String : Any]
        let headers = ["X-RapidAPI-Host" : host, "X-RapidAPI-Key" : key]
        
        let encoding = URLEncoding(arrayEncoding: .noBrackets)
        
        
        Alamofire.request(foodAutoCompleteURL, method: .get, parameters: params, encoding: encoding, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got recipe data")
                let suggestionsJSON : JSON = JSON(response.result.value!)
                var suggestionsArray = [String]()
                if let suggestionJSONObjects = suggestionsJSON.array {
                    for suggestionObject in suggestionJSONObjects {
                        suggestionsArray.append(suggestionObject["name"].stringValue)
                    }
                    self.searchTextField.filterStrings(suggestionsArray)
                    print(suggestionsArray)
                }
            
            } else {
                print("Error \(response.result.error!)")
            }
        }
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
