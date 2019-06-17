//
//  DetailRecipeViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/22/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import SwiftEntryKit
import Segmentio
import Firebase
import Alamofire
import SwiftyJSON
import PromiseKit

class DetailRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentedControl: Segmentio!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
//    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var numberIngredientsLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let amountConversionURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/convert"
    
    var isSavedRecipe : Bool = false
    
    var recipe : Recipe?
    var image : UIImage?
    var listItems = [DetailItem]()
    var userPreferences : [String : Any]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let recipe = recipe {
            print("recipe \(recipe.cuisines)")
            
            creditLabel.text = recipe.creditText
            titleLabel.text = recipe.title
            imageView.sd_setImage(with: URL(string: recipe.imageURL))
        }
        setupSegmentio()
        if isSavedRecipe {
            saveButton.isHidden = true
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName:"DetailItemView", bundle: nil), forCellReuseIdentifier: "listCell")

    }
    
    func setupSegmentio() {
        var content = [SegmentioItem]()
        
        let ingredients = SegmentioItem(title: "Ingredients", image: nil)
        let instructions = SegmentioItem(title: "Instructions", image: nil)
        let nutrition = SegmentioItem(title: "Nutrition", image: nil)
        
        let options = SegmentioOptions(
            backgroundColor: UIColor.clear,
            segmentPosition: .dynamic,
            scrollEnabled: true,
            indicatorOptions: SegmentioIndicatorOptions(
                type: .bottom,
                ratio: 1,
                height: 5,
                color: UIColor(red:0.16, green:0.22, blue:0.27, alpha:1.0)
            ),
            horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(
                type: SegmentioHorizontalSeparatorType.topAndBottom, // Top, Bottom, TopAndBottom
                height: 1,
                color: .gray
            ),
            verticalSeparatorOptions: SegmentioVerticalSeparatorOptions(
                ratio: 0.6, // from 0.1 to 1
                color: .gray
            ),
            imageContentMode: .center,
            labelTextAlignment: .center,
            segmentStates: SegmentioStates(
                defaultState: SegmentioState(
                    backgroundColor: .white,
                    titleFont: UIFont.systemFont(ofSize: UIFont.systemFontSize),
                    titleTextColor: UIColor(named: "Dark Gray") ?? UIColor.darkGray
                ),
                selectedState: SegmentioState(
                    backgroundColor: UIColor(named: "Accent") ?? UIColor.green,
                    titleFont: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
                    titleTextColor: UIColor(named: "Dark Gray") ?? UIColor.darkGray
                ),
                highlightedState: SegmentioState(
                    backgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                    titleFont: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
                    titleTextColor: UIColor(named: "Dark Gray") ?? UIColor.darkGray
                )
            )
        )
        
        content.append(contentsOf: [ingredients, instructions, nutrition])
        segmentedControl.setup(
            content: content,
            style: .onlyLabel,
            options: options
        )
        
        
        
        segmentedControl.valueDidChange = { segmentio, segmentIndex in
            print("Selected item: ", segmentIndex)
            if let recipe = self.recipe {
                self.listItems = [DetailItem]()
                switch segmentIndex{
                case 0: //Ingredients
//                    self.ingredientsTextView.text = recipe.formatIngredients()
                    for ingredient in recipe.ingredients {
                        self.listItems.append(ingredient.toDetailItem())
                    }
                    self.numberIngredientsLabel.text = String(recipe.ingredients.count)
                    self.ingredientsLabel.text = "Ingredients"
                    break
                case 1: //Instructions
//                    if recipe.instructions.count > 0 {
//                        self.ingredientsTextView.text = recipe.ingredients[0].originalName
//                    } else {
//                        self.ingredientsTextView.text = "Unable to find recipe instructions: please visit \(recipe.sourceURL) for original recipe"
//                    }
                    
                    for instruction in recipe.instructions {
                        self.listItems.append(instruction.toDetailItem())
                    }
                    self.numberIngredientsLabel.text = String(recipe.readyInMinutes) + " min"
                    self.ingredientsLabel.text = "Instructions"
                    break
                default: //Nutrition
//                    self.ingredientsTextView.text = ""
                    self.numberIngredientsLabel.text = ""
                    self.ingredientsLabel.text = "Nutrition"
                    for nutrient in recipe.nutrients {
                        self.listItems.append(nutrient.toDetailItem())
                    }
                    break
                }
                print("reloading data")
                self.tableView.reloadData()
            }
        }
        
        segmentedControl.selectedSegmentioIndex = 0
        self.tableView.reloadData()
    }
    
    

    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        print("save button pressed")
        recipe?.saveRecipeIdForUser()
        displaySuccessfulSave()
        updatePreferences()
        self.navigationController?.popViewController(animated: true)
    }
    
    func displaySuccessfulSave() {
        
        /*
         Do some customization on customView
         */
        
        // Attributes struct that describes the display, style, user interaction and animations of customView.
        var attributes = EKAttributes()
        /*
         Adjust preferable attributes
         */
        
        attributes.name = "Saved Recipe!"
        attributes.windowLevel = .normal
        attributes.position = .center
        attributes.displayDuration = 2
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.9)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.4)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        let colors: [UIColor] = [UIColor(named: "Main Green") ?? .green, UIColor(named: "Accent") ?? .blue]
        attributes.entryBackground = .gradient(gradient: .init(colors: colors, startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 16)
        attributes.border = .none
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.2)))
        attributes.entranceAnimation = .init(
            translate: .init(duration: 0.7, anchorPosition: .top, spring: .init(damping: 1, initialVelocity: 0)),
            scale: .init(from: 0.6, to: 1, duration: 0.7),
            fade: .init(from: 0.8, to: 1, duration: 0.3))
        
        // Generate top floating entry and set some properties
        
        let title = EKProperty.LabelContent(text: "Success!", style: .init(font: UIFont(name: "Helvetica Neue", size: 20) ?? UIFont.systemFont(ofSize: 20), color: UIColor(named: "Dark Gray") ?? .black))
        let description = EKProperty.LabelContent(text: "Saved your recipe.", style: .init(font: UIFont(name: "Helvetica Neue-Thin", size: 20) ?? UIFont.systemFont(ofSize: 16), color: UIColor(named: "Dark Gray") ?? .black))

        let image = EKProperty.ImageContent(image: UIImage(named: "tick")!, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        
        
        SwiftEntryKit.display(entry: contentView, using: attributes)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! DetailItemView
        let item = listItems[indexPath.row]
        cell.main.text = item.main
        cell.detail.text = item.detail
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func updatePreferences() {
        let db = Firestore.firestore()
        let currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        currentUserRef.getDocument { (document, error) in
            if let doc = document {
                if var pref = doc.data() {
                    if let r = self.recipe {
                        var cuisineCount = pref["cuisineCount"] as! [String : Int]
                        for cuisine in r.cuisines {
                            let count = cuisineCount[cuisine] ?? 0
                            cuisineCount[cuisine] = count + 5
                        }
                        pref["cuisineCount"] = cuisineCount
                        self.updateIngredientCounts(for: pref, with: r)
                }
            } else {
                    print(error ?? "error")
            }
        }
        

            
        }
    }
    
    func updateIngredientCounts(for pref: [String : Any], with r : Recipe) {
        
        guard let secrets = getPlist(withName: "Secrets") else {fatalError()}
        let host = secrets["Host"]!
        let key = secrets["Key"]!
        let headers = ["X-RapidAPI-Host" : host, "X-RapidAPI-Key" : key]
        
        var promises = [Promise<[String : Double]>]()
        for ing in r.ingredients {
            
            let params = ["sourceUnit" : ing.unit, "sourceAmount" : ing.amount, "ingredientName" : ing.name, "targetUnit" : "grams"] as [String : Any]
//            let amount = 1.0
            let promise = makeRequest(url: amountConversionURL, headers: headers, params: params, ing: ing)
            promises.append(promise)
        }
        
        var ingredientCount = pref["ingredientCount"] as? [String:Double] ?? [String : Double]()
        
        when(fulfilled: promises).done{ results  in
            let isNew : Bool = ingredientCount.isEmpty ? true : false
            ingredientCount = results
                .flatMap { $0 }
                .reduce([String : Double]()) { (dict, tuple)  in
                    var newDict = dict
                    newDict.updateValue(tuple.value, forKey: tuple.key)
                    return newDict
                }
            var preferences = pref
            if isNew {
                preferences["ingredientCount"] = ingredientCount
            } else {
                var ingredientUpdatedCount = preferences["ingredientCount"] as! [String : Double]
                for (food, amount) in ingredientCount {
                    ingredientUpdatedCount[food] = ingredientUpdatedCount[food, default: 0.0] + amount
                }
                preferences["ingredientCount"] = ingredientUpdatedCount
            }
            print(ingredientCount)
            self.save(preferences)
            }
//        print(ingredientCount)
//        return ingredientCount
        
    }
    
    func save(_ preferences: [String : Any]) {
        let db = Firestore.firestore()
        let currentUserRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        currentUserRef.setData(preferences, merge: true)
    }
    
    //MARK: Networking requests to Spoonacular
    func makeRequest(url: String, headers: [String : String], params : [String : Any]?, ing : Ingredient) -> Promise<[String : Double]> {
    
        let encoding = URLEncoding(arrayEncoding: .noBrackets)
        
        return Promise<[String : Double]> {seal in
            Alamofire.request(url, method: .get, parameters: params, encoding: encoding, headers: headers).responseJSON {
                response in
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    print("json \(json)")
                    seal.fulfill([ing.name : json["targetAmount"].double ?? 1.0])
                    
                } else {
                    print("Error \(response.result.error!)")
                    seal.reject(response.result.error!)
                }
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
    
    @IBAction func recipeUrlButtonPressed(_ sender: UIButton) {
        guard let sourceUrl = recipe?.sourceURL else {fatalError()}
        if let url = URL(string: sourceUrl) {
            UIApplication.shared.open(url)
        }
    }
    
}

