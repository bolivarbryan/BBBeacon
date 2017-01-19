//
//  ViewController.swift
//  BBBeacon
//
//  Created by Bryan A Bolivar M on 1/17/17.
//  Copyright © 2017 Bolivar. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.map.delegate = self
        
        for b in BeaconManager.sharedInstance.beacons {
            self.locationLabel.text?.append("\n lat: \(b.latitude!)  long:\(b.longitude!)")
            let c = CLLocationCoordinate2D(latitude: b.latitude!, longitude: b.longitude!)
            let circle = MKCircle(center: c, radius: b.range)
            self.map.add(circle)
        }

        let c = CLLocationCoordinate2D(latitude: 10.96089000 , longitude: -74.79259876)
        let viewRegion = MKCoordinateRegionMakeWithDistance(c, 130, 130)
        map.setRegion(viewRegion, animated: true)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (time) in
            
            if (UIApplication.shared.delegate as! AppDelegate).location != nil {
                self.locationLabel.text = "Lat: \((UIApplication.shared.delegate as! AppDelegate).location!.coordinate.latitude) \n Long: \((UIApplication.shared.delegate as! AppDelegate).location!.coordinate.longitude)" 
            }
            
            self.locationLabel.text?.append("\n\nBEACONS")
            for b in BeaconManager.sharedInstance.beacons {
                self.locationLabel.text?.append("\n lat: \(b.latitude!)  long:\(b.longitude!)")
            }
            
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
        overlayRenderer.lineWidth = 1.0
        overlayRenderer.strokeColor = UIColor.red
        return overlayRenderer
    }
}
