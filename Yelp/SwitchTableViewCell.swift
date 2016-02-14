//
//  SwitchTableViewCell.swift
//  Yelp
//
//  Created by Jerry on 2/9/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchTableViewCellDelegate {
    optional func switchTableViewCell(switchCell: SwitchTableViewCell, didChangeValue value: Bool)
}

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    
    weak var delegate:SwitchTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.onSwitch.addTarget(self, action: "onSwitchSwitched", forControlEvents: UIControlEvents.ValueChanged)
        self.onSwitch.tintColor = UIColor(red: 255/255, green: 126/255, blue: 126/255, alpha: 1)
        self.onSwitch.thumbTintColor = UIColor(red: 255/255, green: 126/255, blue: 126/255, alpha: 1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onSwitchSwitched() {
        self.delegate?.switchTableViewCell?(self, didChangeValue: self.onSwitch.on)
    }

}
