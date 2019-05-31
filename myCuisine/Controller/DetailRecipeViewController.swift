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

class DetailRecipeViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: Segmentio!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var numberIngredientsLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var isSavedRecipe : Bool = false
    
    var recipe : Recipe?
    var image : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let recipe = recipe {
            print("recipe \(recipe.instructions)")
            print("recipe \(recipe.formatIngredients())")
            creditLabel.text = recipe.creditText
            titleLabel.text = recipe.title
            imageView.sd_setImage(with: URL(string: recipe.imageURL))
        }
        setupSegmentio()
        if isSavedRecipe {
            saveButton.isHidden = true
        }
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
                    backgroundColor: UIColor(red:0.16, green:0.22, blue:0.27, alpha:1.0),
                    titleFont: UIFont.systemFont(ofSize: UIFont.systemFontSize + 5),
                    titleTextColor: UIColor(red:0.16, green:0.22, blue:0.27, alpha:1.0)
                ),
                selectedState: SegmentioState(
                    backgroundColor: UIColor(red:0.90, green:0.69, blue:0.18, alpha:1.0),
                    titleFont: UIFont.systemFont(ofSize: UIFont.systemFontSize + 5),
                    titleTextColor: UIColor(red:0.16, green:0.22, blue:0.27, alpha:1.0)
                ),
                highlightedState: SegmentioState(
                    backgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                    titleFont: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize + 5),
                    titleTextColor: .black
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
                switch segmentIndex{
                case 0:
                    self.ingredientsTextView.text = recipe.formatIngredients()
                    self.numberIngredientsLabel.text = String(recipe.ingredients.count)
                    self.ingredientsLabel.text = "Ingredients"
                    break
                case 1:
                    if recipe.instructions.count > 0 {
                        self.ingredientsTextView.text = recipe.ingredients[0].originalName
                    } else {
                        self.ingredientsTextView.text = "Unable to find recipe instructions: please visit \(recipe.sourceURL) for original recipe"
                    }
                    self.numberIngredientsLabel.text = String(recipe.readyInMinutes) + " min"
                    self.ingredientsLabel.text = "Instructions"
                    break
                default:
                    self.ingredientsTextView.text = ""
                    self.numberIngredientsLabel.text = ""
                    self.ingredientsLabel.text = "Nutrition"
                    break
                }
            }
        }
        
        segmentedControl.selectedSegmentioIndex = 0
        
    }
    
    

    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        print("save button pressed")
        recipe?.saveRecipeIdForUser()
        displaySuccessfulSave()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

