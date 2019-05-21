//
//  TableViewCell.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/21/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var numberIngredientsLabel: UILabel!
    @IBOutlet weak var numberMinutesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
