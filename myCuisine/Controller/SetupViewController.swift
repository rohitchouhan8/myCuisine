//
//  SetupViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/16/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var healthLabels = ["vegan", "vegetarian", "paleo", "dairy-free", "gluten-free", "wheat-free", "fat-free", "low-sugar", "egg-free", "peanut-free", "tree-nut-free", "soy-free", "fish-free", "shellfish-free"]
    
    var dietLabels = ["balanced", "high-protein", "high-fiber", "low-fat", "low-carb", "low-sodium"]
    
    var setupDictionary = [Int : [String]]()
    var stepNumber = 0
    @IBOutlet weak var setupTableView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView.delegate = self
        setupTableView.dataSource = self
        
        setupTableView.register(UINib(nibName:"CustomSetupItemCell", bundle: nil) , forCellWithReuseIdentifier: "setupItemCell")
        
        setupDictionary[0] = healthLabels
        setupDictionary[1] = dietLabels
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return setupDictionary[stepNumber]?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = setupTableView.dequeueReusableCell(withReuseIdentifier: "setupItemCell", for: indexPath) as! CustomSetupItemCell
        cell.name.text = healthLabels[indexPath.row]
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        if cell.image.image == nil {
           cell.name.backgroundColor = UIColor(red: 0.16, green: 0.22, blue: 0.27, alpha: 0.85)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = setupTableView.cellForItem(at: indexPath) as! CustomSetupItemCell
        cell.name.backgroundColor = UIColor(red:0.90, green:0.69, blue:0.18, alpha: 0.85)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
    }
    
}
