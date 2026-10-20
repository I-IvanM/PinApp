//
//  LocationAnnotation.swift
//  PinApp
//
//  Created by I_IvanM on 18.08.2026.
//

import Foundation
import MapKit

final class LocationAnnotation: NSObject, MKAnnotation {

    let locationID: UUID
    var color: String

    dynamic var coordinate: CLLocationCoordinate2D

    init(location: Location) {
        self.locationID = location.id
        self.color = location.color
        self.coordinate = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        super.init()
    }
}
