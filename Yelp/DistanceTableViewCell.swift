//
//  DistanceTableViewCell.swift
//  Yelp
//
//  Created by Jerry on 2/14/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol DistanceTableViewCellDelegate {
    optional func distanceTableViewCell(distanceCell: DistanceTableViewCell, didSelectValue value: Int)
}

class DistanceTableViewCell: UITableViewCell {
    
    weak var delegate:DistanceTableViewCellDelegate?

    @IBOutlet weak var distanceSegmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onDistanceSelected(sender: UISegmentedControl) {
        let distance = sender.selectedSegmentIndex
        self.delegate?.distanceTableViewCell!(self, didSelectValue: distance)
    }

}
