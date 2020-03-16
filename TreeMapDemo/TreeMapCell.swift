//
//  TreeMapCell.swift
//  TreeMapDemo
//
//  Created by Kyle Donnelly on 3/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TreeMapCell : UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    func setup(title: String, colorIndex: Int, numColors: Int) {
        self.titleLabel.text = title
        
        // Random-ish background colors spread across the wheel.
        // Make sure first index is not 0, 0, 0 (black).
        self.contentView.backgroundColor = UIColor(red: CGFloat((Int.random(in: 1...5) + colorIndex) * 3 % numColors) / CGFloat(numColors),
                                                   green: CGFloat((Int.random(in: 1...5) + colorIndex) * 5 % numColors) / CGFloat(numColors),
                                                   blue: CGFloat((Int.random(in: 1...5) + colorIndex) * 7 % numColors) / CGFloat(numColors),
                                                   alpha: 0.75)
    }
    
}
