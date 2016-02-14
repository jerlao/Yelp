//
//  SortTableViewCell.swift
//  Yelp
//
//  Created by Jerry on 2/13/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SortTableViewCellDelegate {
    optional func sortTableViewCell(sortCell: SortTableViewCell, didSelectValue value: Int)
}

class SortTableViewCell: UITableViewCell {

    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    weak var delegate:SortTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onSegmentSelected(sender: UISegmentedControl) {
        let getIndex = sender.selectedSegmentIndex
        var selectedValue = 0
        
        if getIndex == 0 {
            selectedValue = getIndex
        } else if getIndex == 1 {
            selectedValue = getIndex
        } else if getIndex == 2 {
            selectedValue = getIndex
        }
        
        self.delegate?.sortTableViewCell!(self, didSelectValue: selectedValue)
    }
    
}
