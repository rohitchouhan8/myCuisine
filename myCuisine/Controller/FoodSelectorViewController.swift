//
//  FoodsSelectorViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/17/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase

class FoodSelectorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var selectedFoods = [String]()
    

    @IBOutlet weak var searchBar: UISearchBar!
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
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = foodsTableView.dequeueReusableCell(withReuseIdentifier: "setupItemCell", for: indexPath) as! CustomSetupItemCell
        cell.name.text = selectedFoods[indexPath.row]
        cell.image.backgroundColor = UIColor(red:0.90, green:0.69, blue:0.18, alpha: 0.85)
        cell.layer.cornerRadius = 8
        print("made cell")
        return cell
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("add button presed")
        if let searchText = searchBar.text {
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
        searchBar.endEditing(true)
        
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
            titleLabel.text = "Liked Foods"
            nextButton.setTitle("Submit", for: .normal)
            save(key: "disliked foods", data: selectedFoods)
            selectedFoods = [String]()
            foodsTableView.reloadData()
        } else {
            save(key: "liked foods", data: selectedFoods)
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
    
}