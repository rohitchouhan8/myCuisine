//
//  SetupViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/16/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase

class SetupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var healthLabels = [DietItem(name: "vegan"), DietItem(name: "vegetarian"), DietItem(name: "paleo"), DietItem(name: "dairy-free"), DietItem(name: "gluten-free"), DietItem(name: "wheat-free"), DietItem(name: "fat-free"), DietItem(name: "low-sugar"), DietItem(name: "egg-free"), DietItem(name: "peanut-free"), DietItem(name: "tree-nut-free"), DietItem(name: "soy-free"), DietItem(name: "fish-free"), DietItem(name: "shellfish-free")]
//    var healthLabels = ["vegan", "vegetarian", "paleo", "dairy-free", "gluten-free", "wheat-free", "fat-free", "low-sugar", "egg-free", "peanut-free", "tree-nut-free", "soy-free", "fish-free", "shellfish-free"]
    var dietLabels = [DietItem(name: "balanced"), DietItem(name: "high-protein"), DietItem(name: "high-fiber"), DietItem(name: "low-fat"), DietItem(name: "low-carb"), DietItem(name: "low-sodium")]
    //    var dietLabels = ["balanced", "high-protein", "high-fiber", "low-fat", "low-carb", "low-sodium"]
    var setupArray = [[DietItem]]()
    var stepNumber = 0
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var setupTableView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView.delegate = self
        setupTableView.dataSource = self
        
        setupTableView.register(UINib(nibName:"CustomSetupItemCell", bundle: nil) , forCellWithReuseIdentifier: "setupItemCell")
        
        setupArray.append(healthLabels)
        setupArray.append(dietLabels)
        nextButton.layer.cornerRadius = 8
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return setupArray[stepNumber].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = setupTableView.dequeueReusableCell(withReuseIdentifier: "setupItemCell", for: indexPath) as! CustomSetupItemCell
        let dataSource = setupArray[stepNumber]
        cell.name.text = dataSource[indexPath.row].name
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        if dataSource[indexPath.row].selected {
            cell.image.backgroundColor = UIColor(red:0.90, green:0.69, blue:0.18, alpha: 0.85)
        } else {
            cell.image.backgroundColor = UIColor(red: 0.16, green: 0.22, blue: 0.27, alpha: 0.85)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = setupTableView.cellForItem(at: indexPath) as! CustomSetupItemCell
        let dataSource = setupArray[stepNumber]
        dataSource[indexPath.row].selected = !dataSource[indexPath.row].selected
        if dataSource[indexPath.row].selected {
            cell.image.backgroundColor = UIColor(red:0.90, green:0.69, blue:0.18, alpha: 0.85)
        } else {
            cell.image.backgroundColor = UIColor(red: 0.16, green: 0.22, blue: 0.27, alpha: 0.85)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if stepNumber == setupArray.count - 1 {
            saveData()
            performSegue(withIdentifier: "goToMain", sender: self)
        } else {
            
            if stepNumber == setupArray.count - 2 {
                nextButton.titleLabel?.text = "Submit"
            }
            print(stepNumber)
            stepNumber += 1
            setupTableView.reloadData()
        }
    }
    
    func saveData() {
        let currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        let formattedData = formatData()
        print(formatData())
        currentUserRef.setData(formattedData) { (error) in
            if let err = error {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func formatData() -> [String: [String]] {
        var unselectedHealthLabels = [String]()
        var selectedHealthLabels = [String]()
        var unselectedDietLabels = [String]()
        var selectedDietLabels = [String]()
        
        for healthLabel in healthLabels {
            if healthLabel.selected {
                selectedHealthLabels.append(healthLabel.name)
            } else {
                unselectedHealthLabels.append(healthLabel.name)
            }
        }
        for dietLabel in dietLabels {
            if dietLabel.selected {
                selectedDietLabels.append(dietLabel.name)
            } else {
                unselectedDietLabels.append(dietLabel.name)
            }
        }
        return ["unselectedHL" : unselectedHealthLabels,
                "selectedHL" : selectedHealthLabels,
                "unselectedDL" : unselectedDietLabels,
                "selectedDL" : selectedDietLabels]
    }
    
}
