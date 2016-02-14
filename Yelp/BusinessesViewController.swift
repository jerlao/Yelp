//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import AFNetworking
import MapKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate, MKMapViewDelegate {
    
    var businesses: [Business]!
    let searchBar = UISearchBar()
    var isMap = false
    var counter = 0
    var refreshMap = true
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.mapView.delegate = self
        self.navigationItem.titleView = self.searchBar
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 126/255, blue: 126/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let rightButton = UIBarButtonItem(title: "Map", style: .Plain, target: self, action: "showMap")
        self.navigationItem.rightBarButtonItem = rightButton
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
        //cell.thumbImageView.setImageWithURL(business.imageURL!)
        if let imgUrl = business.imageURL {
            cell.thumbImageView.setImageWithURL(imgUrl, placeholderImage: UIImage(named: "image"))
        } else {
            cell.thumbImageView.image = UIImage(named: "image")
        }
        cell.ratingImageView.setImageWithURL(business.ratingImageURL!)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchKeyword(searchBar.text!)
        self.searchBar.resignFirstResponder()
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.refreshMap = true
        self.isMap = false
        self.mapView.hidden = true
        self.tableView.hidden = false
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
        
        self.isMap = false
        self.mapView.hidden = true
        self.tableView.hidden = false
        self.navigationItem.rightBarButtonItem?.title = "Map"
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.refreshMap = true
        self.searchBar.text = ""
        
        let categories = filters["categories"] as? [String]
        let deals = filters["deals"] as? Bool
        let sortNum = filters["sort"] as? Int
        let sort = YelpSortMode(rawValue: sortNum!)
        
        Business.searchWithTerm("Restaurants", sort: sort, categories: categories, deals: deals) { (business: [Business]!, error: NSError!) -> Void in
            self.businesses = business
            self.tableView.reloadData()
        }
    
    }
    
    func showMap() {
        if !self.isMap {
            self.tableView.hidden = true
            self.mapView.hidden = false
            self.isMap = true
            self.navigationItem.rightBarButtonItem?.title = "List"
            self.counter = 0
            if self.refreshMap {
                self.loopThroughBusinesses()
                self.refreshMap = false
            }
            
        } else {
            self.tableView.hidden = false
            self.mapView.hidden = true
            self.isMap = false
            self.navigationItem.rightBarButtonItem?.title = "Map"
        }
    }
    
    func loopThroughBusinesses() {
        for business in self.businesses {
            addBusinessToMap(business)
        }
        
        self.zoomToFill()
    }
    
    func addBusinessToMap(business: Business) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString((business.detail_address)!) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else if placemarks!.count > 0 {
                let placemark = placemarks![0]
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = (placemark.location?.coordinate)!
                annotation.title = business.name
                self.mapView.addAnnotation(annotation)
            }
            self.counter++
            if self.counter == self.businesses.count {
                self.zoomToFill()
            }
        }
        
    }
    
    func zoomToFill() {
        var zoomRect = MKMapRectNull
        for annotation in self.mapView.annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.05, 0.05)
            if (MKMapRectIsNull(zoomRect)) {
                zoomRect = pointRect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, pointRect)
            }
        }
        
        let edgeInset = UIEdgeInsetsMake(50, 50, 50, 50)
        self.mapView.setVisibleMapRect(zoomRect, edgePadding: edgeInset, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detailSegue" {
            let destination = segue.destinationViewController as! DetailViewController
            let cell = sender as! BusinessTableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            destination.business = self.businesses[(indexPath?.row)!]
        } else {
            let destination = segue.destinationViewController as! UINavigationController
            let filtersVC = destination.topViewController as! FiltersViewController
            
            filtersVC.delegate = self
        }
    }
    
}
