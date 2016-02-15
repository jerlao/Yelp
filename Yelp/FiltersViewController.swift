//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Jerry on 2/9/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateField filters: [String: AnyObject])
}

class FiltersViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, SwitchTableViewCellDelegate, DealSwitchTableViewCellDelegate, SortTableViewCellDelegate, DistanceTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    var categories:[[String:String]]?
    var catSwitchStates = [Int:Bool]()
    var sortBy = 0
    var distance = 0
    var deals = false
    
    let sections = ["", "Sort By", "Distance", "Category"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 126/255, blue: 126/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.categories = self.getCategories()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let section = indexPath.section
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("dealCell") as! DealSwitchTableViewCell
            cell.delegate = self
            cell.dealLabel.text = "Offering a Deal"
            cell.dealSwitch.on = self.deals
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("sortCell") as! SortTableViewCell
            cell.delegate = self
            cell.sortSegmentedControl.selectedSegmentIndex = self.sortBy
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("distanceCell") as! DistanceTableViewCell
            cell.delegate = self
            cell.distanceSegmentedControl.selectedSegmentIndex = self.distance
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("switchCell") as! SwitchTableViewCell
            cell.delegate = self
            cell.switchLabel.text = self.categories![indexPath.row]["name"]
            cell.onSwitch.on = self.catSwitchStates[indexPath.row] ?? false
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("switchCell") as! SwitchTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return (self.categories?.count)!
        default:
            return 0
        }
    }
    
    func switchTableViewCell(switchCell: SwitchTableViewCell, didChangeValue value: Bool) {
        let indexPath = self.tableView.indexPathForCell(switchCell)
        self.catSwitchStates[indexPath!.row] = value
    }
    
    func dealSwitchTableViewCell(dealCell: DealSwitchTableViewCell, didChangeValue value: Bool) {
        self.deals = value
    }
    
    func sortTableViewCell(sortCell: SortTableViewCell, didSelectValue value: Int) {
        self.sortBy = value
    }
    
    func distanceTableViewCell(distanceCell: DistanceTableViewCell, didSelectValue value: Int) {
        var distanceValue = 0
        switch value {
        case 0:
            distanceValue = 0
        case 1:
            distanceValue = 480
        case 2:
            distanceValue = 1600
        case 3:
            distanceValue = 8000
        case 4:
            distanceValue = 32000
        default:
            distanceValue = 0
        }
        self.distance = distanceValue
    }
    
    
    @IBAction func onCancelPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            //
        }
    }
    
    
    @IBAction func onSearchPressed(sender: UIBarButtonItem) {
        var filters = [String:AnyObject]()
        
        var selectedCategories = [String]()
        
        for (row, isSelected) in catSwitchStates {
            if isSelected {
                selectedCategories.append(self.categories![row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        filters["deals"] = self.deals
        filters["sort"] = self.sortBy
        filters["distance"] = self.distance
        
        self.delegate?.filtersViewController!(self, didUpdateField: filters)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getCategories() -> [[String: String]] {
        return [
            ["name" : "Burgers", "code": "burgers"],
            ["name" : "Chinese", "code": "chinese"],
            ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
            ["name" : "Steakhouses", "code": "steak"],
            ["name" : "Sushi Bars", "code": "sushi"]]
    }

}
