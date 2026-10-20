//
//  AuthorizationManager.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import CoreLocation

final class AuthorizationManager {

    func requestWhenInUseAuthorization(
        using locationManager: CLLocationManager
    ) {
        locationManager.requestWhenInUseAuthorization()
    }

    func isAuthorized(
        _ status: CLAuthorizationStatus
    ) -> Bool {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return true

        default:
            return false
        }
    }
}
