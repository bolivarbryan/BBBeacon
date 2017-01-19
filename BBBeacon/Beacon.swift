//
//  Beacon.swift
//  BBBeacon
//
//  Created by Bryan A Bolivar M on 1/17/17.
//  Copyright © 2017 Bolivar. All rights reserved.
//

import Foundation

struct Beacon {
    let name: String
    let latitude: Double?
    let longitude: Double?
    let url: String
    let uuid: String
    let school: String
    let beaconId: Int
    var range: Double
    
    init(name: String, latitude: Double?, longitude: Double?, url: String, school: String, beaconId: Int, uuid: String, range: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.url = url
        self.name = name
        self.beaconId = beaconId
        self.uuid = uuid
        self.school = school
        self.range = range
    }
}
