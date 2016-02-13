//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import AFNetworking

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate {
    
    var businesses: [Business]!
    let searchBar = UISearchBar()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = self.searchBar
        self.searchBar.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        
        self.searchKeyword("Restaurant")
        
        /* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
        self.businesses = businesses
        
        for business in businesses {
        print(business.name!)
        print(business.address!)
        }
        }
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let businesses = self.businesses {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell") as! BusinessTableViewCell
        let business = self.businesses[indexPath.row]
        cell.nameLabel.text = business.name
        cell.reviewsLabel.text = business.reviewCount!.stringValue
        cell.categoryLabel.text = business.categories
        cell.distanceLabel.text = business.distance
        cell.addressLabel.text = business.address
        cell.thumbImageView.setImageWithURL(business.imageURL!)
        cell.ratingImageView.setImageWithURL(business.ratingImageURL!)
        
        return cell
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchKeyword(searchBar.text!)
        self.searchBar.resignFirstResponder()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchKeyword(keyword: String) {
        Business.searchWithTerm(keyword, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
            
        })
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateField filters: [String : AnyObject]) {
        let categories = filters["categories"] as? [String]
        let deals = ""
        let sort = ""
        Business.searchWithTerm("Restaurants", sort: nil, categories: categories, deals: nil) { (business: [Business]!, error: NSError!) -> Void in
            self.businesses = business
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        let destination = segue.destinationViewController as! UINavigationController
        let filtersVC = destination.topViewController as! FiltersViewController
        
        filtersVC.delegate = self
    }
    
}
