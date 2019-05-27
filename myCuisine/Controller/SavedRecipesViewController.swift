//
//  SecondViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/15/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase
class SavedRecipesViewController: RecipeListViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var recipeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        // Do any additional setup after loading the view.
        configureTableView()
        
        currentUserRef?.addSnapshotListener({ (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            self.recipes = [Recipe]()
            self.getRecipesFrom(data: data)
            
        })
    }
    
    override func loadRecipes() {
        guard let userRef = currentUserRef else {fatalError()}
        userRef.getDocument { (document, error) in
            print("started")
            if let document = document, document.exists {
                if let userData = document.data() {
                    self.getRecipesFrom(data: userData)
                }
            }
        }
    }
    
    func getRecipesFrom(data : [String : Any]) {
        let recipesCollectionRef = db.collection("recipes")
        if let savedRecipeIds = data["savedRecipes"] as? [Int] {
            for recipeId in savedRecipeIds {
                let recipeDocument = recipesCollectionRef.document(String(recipeId))
                recipeDocument.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let data = document.data() {
                            let recipe = self.getRecipeFromFirestore(data: data)
                            self.recipes.append(recipe)
                            self.recipeTableView.reloadData()
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    //Configures table view to set the delegate and data source properties. It also sets the row height and the custom recipe cell to use for display.
    override func configureTableView() {
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
        recipeTableView.register(UINib(nibName:"RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "recipeCell")
        recipeTableView.rowHeight = CGFloat(rowHeight)
        
        recipeTableView.separatorStyle = .none
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recipeTableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
        let recipe = recipes[indexPath.row]
        cell.recipeNameLabel.text = recipe.title
        cell.creditLabel.text = recipe.creditText
        cell.numberMinutesLabel.text = String(recipe.readyInMinutes)
        cell.numberIngredientsLabel.text = String(recipe.ingredients.count)
        
        cell.recipeImageView.sd_setImage(with: URL(string: recipe.imageURL))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc2 = DetailRecipeViewController()
        
        // this enables Hero
        vc2.hero.isEnabled = true
        
        // this configures the built in animation
        //    vc2.hero.modalAnimationType = .zoom
        //    vc2.hero.modalAnimationType = .pageIn(direction: .left)
        //    vc2.hero.modalAnimationType = .pull(direction: .left)
        //    vc2.hero.modalAnimationType = .autoReverse(presenting: .pageIn(direction: .left))
        vc2.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .fade)
        
        //        // lastly, present the view controller like normal
        //        present(vc2, animated: true, completion: nil)
        
        performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetailRecipeViewController
        if let indexPath = recipeTableView.indexPathForSelectedRow {
            let recipe = recipes[indexPath.row]
            destinationVC.recipe = recipe
        }
    }
    


}

