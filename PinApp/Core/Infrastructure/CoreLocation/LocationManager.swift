//
//  LocationManager.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject {

    @Published private(set) var location: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    private let locationManager: CLLocationManager
    private let authorizationManager: AuthorizationManager

    private var pendingCompletion: ((CLLocationCoordinate2D) -> Void)?

    init(
        authorizationManager: AuthorizationManager = AuthorizationManager()
    ) {
        let locationManager = CLLocationManager()

        self.locationManager = locationManager
        self.authorizationManager = authorizationManager
        self.authorizationStatus = locationManager.authorizationStatus

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestCurrentLocation(
        completion: @escaping (CLLocationCoordinate2D) -> Void
    ) {
        pendingCompletion = completion

        switch locationManager.authorizationStatus {
        case .notDetermined:
            authorizationManager.requestWhenInUseAuthorization(
                using: locationManager
            )

        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()

        case .denied, .restricted:
            pendingCompletion = nil

        @unknown default:
            pendingCompletion = nil
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus

            if self.authorizationManager.isAuthorized(
                manager.authorizationStatus
            ) {
                manager.requestLocation()
            } else {
                self.pendingCompletion = nil
            }
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else {
            return
        }

        DispatchQueue.main.async {
            self.location = location

            self.pendingCompletion?(
                location.coordinate
            )

            self.pendingCompletion = nil
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Failed to get user location: \(error)")
        pendingCompletion = nil
    }
}
