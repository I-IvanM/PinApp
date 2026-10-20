//
//  MapStyle+Extensions.swift
//  PinApp
//
//  Created by I_IvanM on 25.08.2026.
//

import Foundation
import MapKit

extension MapStyle {

    var mapKitMapType: MKMapType {
        switch self {
        case .standard:
            return .standard

        case .satellite:
            return .satellite

        case .hybrid:
            return .hybrid
        }
    }
}
