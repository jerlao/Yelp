//
//  DetailViewController.swift
//  Yelp
//
//  Created by Jerry on 2/13/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AFNetworking

class DetailViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var business: Business?
    var bPlacemark: CLPlacemark?
    var directions = ""
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = self.business?.name!
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        self.mapView.delegate = self
        
        let directionsButton = UIBarButtonItem(title: "Directions", style: .Plain, target: self, action: "directionsSegue")
        self.navigationItem.rightBarButtonItem = directionsButton
        
        self.addBusinessToMap()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBusinessToMap() {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString((self.business?.detail_address)!) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else if placemarks!.count > 0 {
                let placemark = placemarks![0]
                self.bPlacemark = placemark
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = (placemark.location?.coordinate)!
                annotation.title = self.business?.name
                self.mapView.addAnnotation(annotation)
                self.addSelfToMap()
            }
        }
    }
    
    func addSelfToMap() {
        
        let currentPosition = MKPointAnnotation()
        currentPosition.coordinate = CLLocationCoordinate2DMake(37.785771, -122.406165)
        currentPosition.title = "Me"
        self.mapView.addAnnotation(currentPosition)
        self.locationManager.stopUpdatingLocation()
        self.getDirectionsTo(self.business!)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.title! != "Me" {
            let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            let business = self.business!
            if let imageUrl = business.imageURL {
                let data = NSData(contentsOfURL: imageUrl)
                let image = UIImage(data: data!)
                
                pin.image = self.scaleImage(image!)
                pin.layer.cornerRadius = pin.frame.size.width / 2
                pin.layer.masksToBounds = true
                pin.layer.borderColor = UIColor(red: 255/255, green: 126/255, blue: 126/255, alpha: 1).CGColor
                pin.layer.borderWidth = 5
            } else {
                let image = UIImage(named: "image")
                pin.image = self.scaleImage(image!)
                pin.layer.cornerRadius = pin.frame.size.width / 2
                pin.layer.masksToBounds = true
                pin.layer.borderColor = UIColor(red: 255/255, green: 126/255, blue: 126/255, alpha: 1).CGColor
                pin.layer.borderWidth = 5
            }
            // pin.canShowCallout = true
            // pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
            return pin
        } else {
            let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.canShowCallout = true
            
            return pin
        }
    }
    
    func scaleImage(image: UIImage) -> UIImage {
        let size = CGSize(width: 50, height: 50)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.drawInRect(CGRect(x: 0,y: 0,width: size.height,height: size.width))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func getDirectionsTo(destination: Business) {
        let request = MKDirectionsRequest()
        if let getPlacemark = self.bPlacemark {
            let newPlacemark = MKPlacemark(placemark: getPlacemark)
            let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(37.785771, -122.406165), addressDictionary: nil)
            request.source = MKMapItem(placemark: sourcePlacemark)
            let mapI = MKMapItem(placemark: newPlacemark)
            request.destination = mapI
            request.transportType = MKDirectionsTransportType.Automobile
            let directions = MKDirections(request: request)
            directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
                let routes = response?.routes
                let route = routes?.first
                if let steps = route?.steps {
                    var counter = 1
                    for step in steps {
                        self.directions = self.directions.stringByAppendingString("\(counter): "+step.instructions+"\n\n")
                        ++counter
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.drawDirections()
                    
                })
            }
        }
    }
    
    func drawDirections() {
        let request = MKDirectionsRequest()
        if let getPlacemark = self.bPlacemark {
            let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(37.785771, -122.406165), addressDictionary: nil)
            request.source = MKMapItem(placemark: sourcePlacemark)
            let mkPlacemark = MKPlacemark(placemark: getPlacemark)
            let mapI = MKMapItem(placemark: mkPlacemark)
            request.destination = mapI
            request.transportType = MKDirectionsTransportType.Automobile
            let directions = MKDirections(request: request)
            directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
                let routes = response?.routes
                let route = routes?.first
                let line = route?.polyline
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.mapView .addOverlay(line!)
                    self.zoomToPolyLine(self.mapView, polyline: line!, animated: true)
                })
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor(red: 255/255, green: 125/255, blue: 126/255, alpha: 1)
        renderer.lineWidth = 2.0
        return renderer
    }
    
    func zoomToPolyLine(map: MKMapView, polyline: MKPolyline, animated: Bool) {
        map.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsetsMake(50, 50, 50, 50), animated: animated)
    }
    
    func directionsSegue() {
        self.performSegueWithIdentifier("directionSegue", sender: nil)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! DirectionViewController
        destination.directionString = self.directions
        destination.businessName = self.business?.name
    }
    
}
