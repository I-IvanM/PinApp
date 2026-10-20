//
//  PolygonSearch.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import MapKit

final class PolygonSearch {

    private let polygonIndex: PolygonIndex

    init(polygonIndex: PolygonIndex) {
        self.polygonIndex = polygonIndex
    }

    func search(
        countries: [Country]
    ) -> [MKMultiPolygon] {
        var polygons: [MKMultiPolygon] = []

        for country in countries {
            guard let polygon = polygonIndex.polygon(
                for: country.countryID
            ) else {
                print("Polygon not found for country: \(country.countryID)")
                continue
            }

            polygons.append(polygon)
        }

        return polygons
    }
}
