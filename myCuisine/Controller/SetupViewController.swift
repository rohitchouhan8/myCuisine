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
    var cuisine = [DietItem(name: "african"), DietItem(name: "chinese"), DietItem(name: "japanese"), DietItem(name: "korean"), DietItem(name: "vietnamese"), DietItem(name: "thai"), DietItem(name: "indian"), DietItem(name: "british"), DietItem(name: "irish"), DietItem(name: "french"), DietItem(name: "italian"), DietItem(name: "mexican"), DietItem(name: "spanish"), DietItem(name: "middle eastern"), DietItem(name: "jewish"), DietItem(name: "american"), DietItem(name: "cajun"), DietItem(name: "southern"), DietItem(name: "greek"), DietItem(name: "german"), DietItem(name: "nordic"), DietItem(name: "eastern european"), DietItem(name: "caribbean"), DietItem(name: "latin american")]
    //african, chinese, japanese, korean, vietnamese, thai, indian, british, irish, french, italian, mexican, spanish, middle eastern, jewish, american, cajun, southern, greek, german, nordic, eastern european, caribbean, or latin american
    
    var dietLabels = [DietItem(name: "pescetarian"), DietItem(name: "lacto vegetarian"), DietItem(name: "ovo vegetarian"), DietItem(name: "vegan"), DietItem(name: "vegetarian")]
    //pescetarian, lacto vegetarian, ovo vegetarian, vegan, and vegetarian


    
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
        
        setupArray.append(cuisine)
        setupArray.append(dietLabels)
        nextButton.layer.cornerRadius = 8
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(setupArray[stepNumber].count)
        return setupArray[stepNumber].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = setupTableView.dequeueReusableCell(withReuseIdentifier: "setupItemCell", for: indexPath) as! CustomSetupItemCell
        let dataSource = setupArray[stepNumber]
        cell.name.text = dataSource[indexPath.row].name
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        if dataSource[indexPath.row].selected {
            // Yellow background
            cell.image.backgroundColor = UIColor(red:0.90, green:0.69, blue:0.18, alpha: 0.85)
        } else {
            //Gray background
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
        stepNumber += 1
        if stepNumber == setupArray.count {
            saveData()
            performSegue(withIdentifier: "goToFoods", sender: self)
        } else if stepNumber == setupArray.count - 1 {
            nextButton.setTitle("Submit", for: .normal)
            setupTableView.reloadData()
        } else {
            setupTableView.reloadData()
        }
        
//        if stepNumber == setupArray.count - 1 {
//            saveData()
//            performSegue(withIdentifier: "goToMain", sender: self)
//        } else {
//
//            if stepNumber == setupArray.count - 2 {
//                nextButton.titleLabel?.text = "Submit"
//            }
//            print(stepNumber)
//            stepNumber += 1
//            setupTableView.reloadData()
//        }
    }
    
    func saveData() {
        let currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        let formattedData = formatData()
        currentUserRef.setData(formattedData) { (error) in
            if let err = error {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func formatData() -> [String: Any] {
        var cuisinesDictionary = [String : Int]()
        var unselectedDietLabels = [String]()
        var selectedDietLabels = [String]()
        
        for c in cuisine {
            if c.selected {
                cuisinesDictionary[c.name] = 2 * cuisine.count
            } else {
                cuisinesDictionary[c.name] = 1
            }
        }
        for dietLabel in dietLabels {
            if dietLabel.selected {
                selectedDietLabels.append(dietLabel.name)
            } else {
                unselectedDietLabels.append(dietLabel.name)
            }
        }
        return ["cuisineCount" : cuisinesDictionary,
                "unselectedDL" : unselectedDietLabels,
                "selectedDL" : selectedDietLabels]
    }
    
    
    
}
