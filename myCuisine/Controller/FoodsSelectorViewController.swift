//
//  FoodsSelectorViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/17/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase

class FoodsSelectorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var selectedFoods = [String]()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectedFoodsTableView: UICollectionView!
    @IBOutlet weak var foodsTableView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    let db = Firestore.firestore()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        foodsTableView.delegate = self
        foodsTableView.dataSource = self
        foodsTableView.register(UINib(nibName:"CustomSetupItemCell", bundle: nil) , forCellWithReuseIdentifier: "setupItemCell")
        addButton.layer.cornerRadius = 8
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = setupTableView.dequeueReusableCell(withReuseIdentifier: "setupItemCell", for: indexPath) as! CustomSetupItemCell
        cell.name.text = selectedFoods[indexPath.row]
        cell.image.backgroundColor = UIColor(red:0.90, green:0.69, blue:0.18, alpha: 0.85)
        return cell
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        if let searchText = searchBar.text {
            selectedFoods.append(searchText)
        }
        foodsTableView.reloadData()
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
        if nextButton.titleLabel?.text == "Next" {
            nextButton.titleLabel?.text = "Submit"
            save(key: "disliked foods", data: selectedFoods)
            selectedFoods = [String]()
        } else {
            save(key: "liked foods", data: selectedFoods)
            performSegue(withIdentifier: "goToMain", sender: self)
        }
        
    }
    
    func save(key: String, data: [String]) {
        let currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        currentUserRef.setData([key: data]) { (error) in
            if let err = error {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
}
