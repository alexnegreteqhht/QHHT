//
//  Location.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/17/23.
//

import Foundation
import CoreLocation
import CoreLocationUI

extension CLLocationManager {
    func startUpdatingLocationOnce() {
        requestWhenInUseAuthorization()
        startUpdatingLocation()
    }
}

class EditProfileViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.startUpdatingLocationOnce()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            manager.stopUpdatingLocation()
        }
    }
}
