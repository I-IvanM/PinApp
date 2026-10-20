//
//  MapView.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    let dependencies: AppDependencies
    
    @StateObject private var locationManager = LocationManager()
    @State private var pinPresentation: PinPresentation?
    @State private var userLocation: CLLocationCoordinate2D?
    

    var body: some View {
        let _ = dependencies.updateService.mapUpdate
        let locations = fetchLocations()
        let visitedCountries = fetchVisitedCountries()
        
        print("Visited countries: \(visitedCountries.map(\.countryID))")

        return ZStack {
            MKMapViewRepresentable(
                mapStyle: dependencies.settingsService.mapStyle,
                locations: locations,
                visitedCountries: visitedCountries,
                settingsService: dependencies.settingsService,
                polygonSearch: dependencies.polygonSearch,
                userLocation: userLocation,

                onLongPress: { coordinate in
                    let pinCoordinate = roundedTo(
                        Coordinate(
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude,
                            altitude: nil
                        ), 6
                    )

                    pinPresentation = .coordinate(pinCoordinate)
                },
                onLocationSelected: { locationID in
                    pinPresentation = .location(locationID)
                }
            )
            .ignoresSafeArea()
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 60)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
                    .blur(radius: 20)
            }

            MapToolbar {
                showUserLocation()
            }
        }
        .sheet(item: $pinPresentation) { presentation in
            switch presentation {
            case .newPin:
                PinView(
                    dependencies: dependencies
                )

            case .coordinate(let coordinate):
                PinView(
                    dependencies: dependencies,
                    coordinate: coordinate
                )

            case .location(let locationID):
                PinView(
                    dependencies: dependencies,
                    locationID: locationID,
                    coordinate: nil
                )
            }
        }
    }
    
    private func showUserLocation() {
            locationManager.requestCurrentLocation { coordinate in
                userLocation = coordinate
            }
        }
    
    private func fetchVisitedCountries() -> [Country] {
        do {
            return try dependencies.countryService.fetchVisitedCountries()
        } catch {
            print("Failed to fetch visited countries: \(error)")
            return []
        }
    }
    
    private func fetchLocations() -> [Location] {
        do {
            return try dependencies.locationService.fetchAll()
        } catch {
            print("Failed to fetch locations for map: \(error)")
            return []
        }
    }
}

private enum PinPresentation: Identifiable {
    case newPin
    case coordinate(Coordinate)
    case location(UUID)

    var id: String {
        switch self {
        case .newPin:
            return "newPin"

        case .coordinate(let coordinate):
            return "\(coordinate.latitude),\(coordinate.longitude)"

        case .location(let locationID):
            return locationID.uuidString
        }
    }
}

private func roundedTo(_ coordinate: Coordinate, _ to: Int) -> Coordinate {
    let roundedCoordinate = Coordinate(
        latitude: (coordinate.latitude * pow(10, Double(to))).rounded() / pow(10, Double(to)),
        longitude: (coordinate.longitude * pow(10, Double(to))).rounded() / pow(10, Double(to))
    )
    return roundedCoordinate
}
