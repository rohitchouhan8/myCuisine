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
    
    var isFromSetting = false 

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
        
        if isFromSetting {
            loadPreviousFoods(from: "disliked")
        }
        
    }
    
    func loadPreviousFoods(from key: String) {
        print("loading previous foods")
        let currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        currentUserRef.getDocument { (document, error) in
            if let data = document?.data() {
                self.selectedFoods = data[key] as! [String]
                self.foodsTableView.reloadData()
            } else {
                print("Error retrieving data, \(String(describing: error))")
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = foodsTableView.dequeueReusableCell(withReuseIdentifier: "setupItemCell", for: indexPath) as! CustomSetupItemCell
        cell.name.text = selectedFoods[indexPath.row]
        cell.image.backgroundColor = UIColor(named: "Main Green")?.withAlphaComponent(1.0)
        cell.layer.cornerRadius = 8
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFoods.remove(at: indexPath.row)
        foodsTableView.reloadData()
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
        searchTextField.text = ""
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
            if isFromSetting {
                loadPreviousFoods(from: "intolerable")
            } else {
                selectedFoods = [String]()
            }
            
            foodsTableView.reloadData()
        } else {
            save(key: "intolerable", data: selectedFoods)
            if isFromSetting{
                self.navigationController?.popViewController(animated: true)
            } else {
                performSegue(withIdentifier: "goToMain", sender: self)
            }
            
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
