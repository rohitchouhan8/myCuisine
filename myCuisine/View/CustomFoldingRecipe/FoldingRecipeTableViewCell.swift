//
//  FoldingRecipeTableViewCell.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/22/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import FoldingCell

class FoldingRecipeTableViewCell: FoldingCell {
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.2, 0.2, 0.2]
        return durations[itemIndex % 3]
    }
    
}
