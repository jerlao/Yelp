//
//  DealSwitchTableViewCell.swift
//  Yelp
//
//  Created by Jerry on 2/13/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol DealSwitchTableViewCellDelegate {
    optional func dealSwitchTableViewCell(dealCell: DealSwitchTableViewCell, didChangeValue value: Bool)
}

class DealSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var dealLabel: UILabel!
    @IBOutlet weak var dealSwitch: UISwitch!
    
    weak var delegate:DealSwitchTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.dealSwitch.addTarget(self, action: "onSwitchChanged", forControlEvents: UIControlEvents.ValueChanged)
        self.dealSwitch.tintColor = UIColor(red: 255/255, green: 126/255, blue: 126/255, alpha: 1)
        self.dealSwitch.thumbTintColor = UIColor(red: 255/255, green: 126/255, blue: 126/255, alpha: 1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onSwitchChanged() {
        self.delegate?.dealSwitchTableViewCell?(self, didChangeValue: self.dealSwitch.on)
    }
}
