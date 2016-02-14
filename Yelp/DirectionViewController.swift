//
//  DirectionViewController.swift
//  Yelp
//
//  Created by Jerry on 2/13/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class DirectionViewController: UIViewController {
    
    var directionString: String?
    var businessName: String?

    @IBOutlet weak var directionsTitleLabel: UILabel!
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var closeButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.directionsTitleLabel.text = "Directions to \(self.businessName!)"
        self.directionsLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.directionsLabel.text = self.directionString!
        self.closeButtonOutlet.layer.cornerRadius = 20
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCloseButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            //
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
