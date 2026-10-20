//
//  PolygonLoader.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import MapKit

final class PolygonLoader {

    func loadIndex() throws -> PolygonIndex {
        guard let url = Bundle.main.url(
            forResource: "Countries",
            withExtension: "geojson"
        ) else {
            throw PolygonLoaderError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let objects = try MKGeoJSONDecoder().decode(data)
        let index = PolygonIndex()

        for object in objects {
            guard let feature = object as? MKGeoJSONFeature else {
                continue
            }

            guard let countryID = countryID(from: feature) else {
                continue
            }

            guard let polygon = polygon(from: feature) else {
                continue
            }

            index.setPolygon(
                polygon,
                for: countryID
            )
        }

        return index
    }

    // MARK: - Private

    private func countryID(
        from feature: MKGeoJSONFeature
    ) -> String? {
        guard let properties = feature.properties else {
            return nil
        }

        guard let dictionary = try? JSONSerialization.jsonObject(
            with: properties
        ) as? [String: Any] else {
            return nil
        }

        if let countryID = dictionary["ISO_A2"] as? String,
           countryID.count == 2 {
            return countryID
        }

        if let countryID = dictionary["ISO_A2_EH"] as? String,
           countryID.count == 2 {
            return countryID
        }

        return nil
    }

    private func polygon(
        from feature: MKGeoJSONFeature
    ) -> MKMultiPolygon? {
        var polygons: [MKPolygon] = []

        for geometry in feature.geometry {
            if let polygon = geometry as? MKPolygon {
                polygons.append(polygon)
            } else if let multiPolygon = geometry as? MKMultiPolygon {
                polygons.append(contentsOf: multiPolygon.polygons)
            }
        }

        guard !polygons.isEmpty else {
            return nil
        }

        return MKMultiPolygon(polygons)
    }
}

enum PolygonLoaderError: Error {
    case fileNotFound
}
