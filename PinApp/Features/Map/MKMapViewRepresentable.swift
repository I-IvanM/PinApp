//
//  MKMapViewRepresentable.swift
//  PinApp
//
//  Created by I_IvanM on 18.08.2026.
//

import Foundation
import SwiftUI
import MapKit

struct MKMapViewRepresentable: UIViewRepresentable {

    let mapStyle: MapStyle
    let locations: [Location]
    let visitedCountries: [Country]
    let settingsService: SettingsService
    let polygonSearch: PolygonSearch
    let userLocation: CLLocationCoordinate2D?

    let onLongPress: (CLLocationCoordinate2D) -> Void
    let onLocationSelected: (UUID) -> Void

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(
            onLongPress: onLongPress,
            onLocationSelected: onLocationSelected,
            polygonRenderer: PolygonRenderer(),
            settingsService: settingsService
        )
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()

        mapView.mapType = mapStyle.mapKitMapType
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator

        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(
                MapCoordinator.handleLongPress(_:)
            )
        )

        mapView.addGestureRecognizer(longPressGesture)

        return mapView
    }

    func updateUIView(
        _ mapView: MKMapView,
        context: Context
    ) {
        mapView.mapType = mapStyle.mapKitMapType

        context.coordinator.mapRenderer.update(
            locations: locations,
            on: mapView
        )

        let polygons = polygonSearch.search(
            countries: visitedCountries
        )

        context.coordinator.polygonRenderer.render(
            polygons: polygons,
            on: mapView
        )

        if let userLocation {
            context.coordinator.showUserLocation(userLocation, on: mapView)
        }
    }
}
