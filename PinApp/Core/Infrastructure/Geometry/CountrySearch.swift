//
//  CountrySearch.swift
//  PinApp
//
//  Created by I_IvanM on 23.08.2026.
//

import Foundation
import MapKit

final class CountrySearch {

    private let polygonIndex: PolygonIndex
    private let pointInPolygon: PointInPolygon

    init(
        polygonIndex: PolygonIndex,
        pointInPolygon: PointInPolygon
    ) {
        self.polygonIndex = polygonIndex
        self.pointInPolygon = pointInPolygon
    }

    func search(
        coordinate: Coordinate
    ) -> String {

        let mapPoint = MKMapPoint(
            CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        )

        for countryID in countryIDs() {
            let polygons = polygonIndex.indexedPolygons(
                for: countryID
            )

            for indexedPolygon in polygons {
                guard indexedPolygon.boundingBox.contains(mapPoint) else {
                    continue
                }

                guard pointInPolygon.contains(
                    coordinate: coordinate,
                    in: indexedPolygon.polygon
                ) else {
                    continue
                }

                return countryID
            }
        }

        return "XZ"
    }

    // MARK: - Private

    private func countryIDs() -> [String] {
        polygonIndex.countryIDs
    }
}
