//
//  SearchService.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import CoreLocation
import MapKit

final class SearchService {

    func search(
        query: String,
        near coordinate: Coordinate? = nil
    ) async -> Coordinate? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        if let coordinate {
            request.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                ),
                latitudinalMeters: 50_000,
                longitudinalMeters: 50_000
            )
        }

        let search = MKLocalSearch(request: request)

        do {
            let response = try await search.start()

            let coordinates = response.mapItems.map {
                makeCoordinate(from: $0)
            }

            let result = selectCoordinate(
                from: coordinates,
                near: coordinate
            )

            print("Search coordinate: \(String(describing: result))")

            return result
        } catch {
            print("Search failed: \(error)")

            return nil
        }
    }

    private func makeCoordinate(
        from mapItem: MKMapItem
    ) -> Coordinate {
        let location = mapItem.location

        return Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude
        )
    }

    private func selectCoordinate(
        from coordinates: [Coordinate],
        near sourceCoordinate: Coordinate?
    ) -> Coordinate? {
        guard !coordinates.isEmpty else {
            return nil
        }

        guard let sourceCoordinate else {
            return coordinates.first
        }

        let nearbyCoordinates = coordinates.filter {
            abs($0.latitude - sourceCoordinate.latitude) <= 2.0 &&
            abs($0.longitude - sourceCoordinate.longitude) <= 2.0
        }

        let candidates: [Coordinate]

        if nearbyCoordinates.isEmpty {
            candidates = coordinates
        } else {
            candidates = nearbyCoordinates
        }

        let sourceLocation = CLLocation(
            latitude: sourceCoordinate.latitude,
            longitude: sourceCoordinate.longitude
        )

        return candidates.min { first, second in
            let firstLocation = CLLocation(
                latitude: first.latitude,
                longitude: first.longitude
            )

            let secondLocation = CLLocation(
                latitude: second.latitude,
                longitude: second.longitude
            )

            let firstDistance = sourceLocation.distance(
                from: firstLocation
            )

            let secondDistance = sourceLocation.distance(
                from: secondLocation
            )

            return firstDistance < secondDistance
        }
    }
}
