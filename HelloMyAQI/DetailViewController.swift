//
//  DetailViewController.swift
//  HelloMyRSSReader
//
//  Created by Jim on 2018/6/8.
//  Copyright © 2018年 Jim. All rights reserved.
//

import UIKit
import WebKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    //setter/getter.
    var detailItem: SiteInfo? {
        didSet {
            // Update the view.
            print("\(oldValue) become \(detailItem)") //如果想比較新舊職
            configureView()
        }
    }
    
    func configureView() {
        
        guard let site = detailItem,let mapView = mapView else {
            return
        }//確保拿到站點資訊
        
        guard let lat = Double(site.latitude),
            let lon = Double(site.longitude) else {
            return assertionFailure("Fail to cast Double")
        }
        
        //Show annotation.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        annotation.title = "\(site.county) \(site.siteName) \(site.status)"
        annotation.subtitle = "AQI: \(site.AQI)  PM2.5\(site.pm25)"
        
        mapView.addAnnotation(annotation)
        
        //Move and Zoom the map to the site
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(coordinate, span)
        
        mapView.setRegion(region, animated: true)

        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

