//
//  PolygonIndex.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import MapKit

final class PolygonIndex {

    private var polygonsByCountryID: [
        String: [(polygon: MKPolygon, boundingBox: MKMapRect)]
    ] = [:]

    func setPolygon(
        _ polygon: MKMultiPolygon,
        for countryID: String
    ) {
        var polygons = polygonsByCountryID[countryID] ?? []

        for polygon in polygon.polygons {
            polygons.append(
                (
                    polygon: polygon,
                    boundingBox: polygon.boundingMapRect
                )
            )
        }

        polygonsByCountryID[countryID] = polygons
    }
    
    var countryIDs: [String] {
        Array(polygonsByCountryID.keys)
    }

    func polygon(
        for countryID: String
    ) -> MKMultiPolygon? {

        guard let polygons = polygonsByCountryID[countryID] else {
            return nil
        }

        return MKMultiPolygon(
            polygons.map(\.polygon)
        )
    }

    func indexedPolygons(
        for countryID: String
    ) -> [(polygon: MKPolygon, boundingBox: MKMapRect)] {
        polygonsByCountryID[countryID] ?? []
    }
}
