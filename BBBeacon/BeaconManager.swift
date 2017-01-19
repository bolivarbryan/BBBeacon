//
//  BeaconManager.swift
//  BBBeacon
//
//  Created by Bryan A Bolivar M on 1/17/17.
//  Copyright © 2017 Bolivar. All rights reserved.
//

import Foundation
import CoreLocation

protocol BeaconManagerDelegate {
    func enteredInBeaconZone(beacon: Beacon)
    func updatedToLocation(location: CLLocation)
    func insideBeaconRegion(beacon: Beacon)
}

class BeaconManager: NSObject {

    private(set) var beacons: [Beacon]
    private(set) var locationManager: CLLocationManager
    var delegate: BeaconManagerDelegate?
    var timer = Timer()
    var currentRegion: CLRegion?
    var isBackgroundMode: Bool = false
    var deferringUpdates: Bool = false

    static let sharedInstance : BeaconManager = {
        let instance = BeaconManager(beacons: [])
        return instance
    }()
    
    private init(beacons : [Beacon]) {
        self.beacons = beacons
        self.locationManager = CLLocationManager()
        if let data = (UserDefaults.standard.value(forKey: "BBBeaconCurrentRegion")) {
            let data2 =  NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
            self.currentRegion = data2 as? CLRegion
        }
    }
    
    func registerBeacons(newBeacons: [Beacon]) {
        self.beacons.append(contentsOf: newBeacons)
    }
    
    func removeObjectsInArray(array: [Beacon]) {
        //TODO: use a better implementation
        for object in array {
            var i = 0
            for b in beacons {
                if object.beaconId == b.beaconId {
                    beacons.remove(at: i)
                }
                i += 1
            }
        }
    }
    
    func listActiveBeacons() -> [Beacon] {
        return beacons
    }
    
    func trackBeacons() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.registerBeaconRegions()

    }
    
    func stopUpdatingLocations() {
       
    }
    
    func trackInBackground() {
        isBackgroundMode = true
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.activityType = CLActivityType.automotiveNavigation
        
        self.registerBeaconRegions()

        //TODO: improve this validation
        if let r = self.currentRegion {
            BeaconManager.sharedInstance.locationManager.requestState(for: r)
        }
    }
    
    func finishTracking() {
        self.locationManager.stopUpdatingLocation()
    }
    
     func registerBeaconRegions(){
        for b in self.beacons {
            
            // validate if beacon have a valid coordinate, and ingore those beacons without a valid geopoint
            guard let lat = b.latitude else {
                continue
            }
            
            guard let lng = b.longitude else {
                continue
            }
            
            let c = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let region = self.region(withCoordinate: c , radius: b.range, identifier: b.name)
            
            locationManager.startMonitoring(for: region)
        }
        
        print("Regions monitored: \n \(locationManager.monitoredRegions)")

    }
    
    func region(withCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String) -> CLCircularRegion {
        let region = CLCircularRegion(center: coordinate, radius: radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    
}

extension BeaconManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse ){
            for r in self.locationManager.monitoredRegions {
                self.locationManager.requestState(for: r)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let l = locations.last {
            delegate?.updatedToLocation(location: l)
            
            if (isBackgroundMode == true) && (!deferringUpdates) {
                deferringUpdates = true
                self.locationManager.allowDeferredLocationUpdates(untilTraveled: CLLocationDistanceMax, timeout: 10)
            }
            
            //TODO: improve this validation
            if let r = self.currentRegion {
                BeaconManager.sharedInstance.locationManager.requestState(for: r)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if let _ = delegate {
            
            switch state {
            case .inside:
                self.currentRegion = region
                //encoding and saving to userdefaults
                
                let data = NSKeyedArchiver.archivedData(withRootObject: self.currentRegion)
                
                UserDefaults.standard.set(data, forKey: "BBBeaconCurrentRegion")
                // run each second until user exits the region
                    self.findBeaconByName(region: region)
                break
            case .outside:
                // stops notifications
                break
            case .unknown:
                //stops notification
                break
            }
          
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        deferringUpdates = false
    }
    
    // find beacon
    func findBeaconByName(region:CLRegion) {
        for b in beacons {
            if b.name == region.identifier {
                delegate?.enteredInBeaconZone(beacon: b)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
    }
}
