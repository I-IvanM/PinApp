//
//  PointInPolygon.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import MapKit

final class PointInPolygon {

    func contains(
        coordinate: Coordinate,
        in polygon: MKPolygon
    ) -> Bool {

        let point = CLLocationCoordinate2D(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        guard containsPoint(point, in: polygon) else {
            return false
        }

        for interiorPolygon in polygon.interiorPolygons ?? [] {
            if containsPoint(point, in: interiorPolygon) {
                return false
            }
        }

        return true
    }

    // MARK: - Private

    private func containsPoint(
        _ point: CLLocationCoordinate2D,
        in polygon: MKPolygon
    ) -> Bool {

        let coordinates = coordinates(from: polygon)

        guard coordinates.count >= 3 else {
            return false
        }

        var isInside = false
        var previousIndex = coordinates.count - 1

        for currentIndex in coordinates.indices {
            let current = coordinates[currentIndex]
            let previous = coordinates[previousIndex]

            let crossesHorizontalLine =
                (current.latitude > point.latitude) !=
                (previous.latitude > point.latitude)

            if crossesHorizontalLine {
                let intersectionLongitude =
                    (previous.longitude - current.longitude)
                    * (point.latitude - current.latitude)
                    / (previous.latitude - current.latitude)
                    + current.longitude

                if point.longitude < intersectionLongitude {
                    isInside.toggle()
                }
            }

            previousIndex = currentIndex
        }

        return isInside
    }

    private func coordinates(
        from polygon: MKPolygon
    ) -> [CLLocationCoordinate2D] {

        var coordinates = Array(
            repeating: CLLocationCoordinate2D(),
            count: polygon.pointCount
        )

        polygon.getCoordinates(
            &coordinates,
            range: NSRange(
                location: 0,
                length: polygon.pointCount
            )
        )

        return coordinates
    }
}
