//
//  SecondViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/15/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit
class SavedRecipesViewController: RecipeListViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        // Do any additional setup after loading the view.
        
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
    
    func loadRecipes() {
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
        if let savedRecipeIds = data["savedRecipes"] as? [[String : Any]] {
            for recipeObj in savedRecipeIds {
                let recipeDocument = recipesCollectionRef.document(String(recipeObj["id"] as! Int))
                recipeDocument.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let data = document.data() {
                            let recipe = self.getRecipeFromFirestore(data: data)
                            self.recipes.append(recipe)
                            self.tableView.reloadData()
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }

}

extension SavedRecipesViewController : SwipeTableViewCellDelegate {
    //Tableview Data source methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
        cell.delegate = self
        let recipe = recipes[indexPath.row]
        cell.recipeNameLabel.text = recipe.title
        cell.creditLabel.text = recipe.creditText
        cell.numberMinutesLabel.text = String(recipe.readyInMinutes)
        cell.numberIngredientsLabel.text = String(recipe.ingredients.count)
        
        cell.recipeImageView.sd_setImage(with: URL(string: recipe.imageURL))
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.recipes.remove(at: indexPath.row)
            let recipesToSave = self.recipes.map({(recipe : Recipe) -> [String : Any] in
                return ["id" : recipe.id, "date" : Date().timeIntervalSince1970.magnitude] as [String : Any]
            })
            self.currentUserRef?.setData(["savedRecipes" : recipesToSave], merge: true)
            print("delete cell")
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let vc = segue.destination as! DetailRecipeViewController
        vc.isSavedRecipe = true
    }
}

