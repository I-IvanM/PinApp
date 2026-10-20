//
//  MapCoordinator.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import UIKit
import MapKit

final class MapCoordinator: NSObject, MKMapViewDelegate {

    let mapRenderer: MapRenderer
    let polygonRenderer: PolygonRenderer
    
    private let settingsService: SettingsService
    private let onLongPress: (CLLocationCoordinate2D) -> Void
    
    private var lastUserLocation: CLLocationCoordinate2D?

    init(
        onLongPress: @escaping (CLLocationCoordinate2D) -> Void,
        onLocationSelected: @escaping (UUID) -> Void,
        polygonRenderer: PolygonRenderer,
        settingsService: SettingsService
    ) {
        self.mapRenderer = MapRenderer()
        self.polygonRenderer = polygonRenderer
        self.settingsService = settingsService
        self.onLongPress = onLongPress

        super.init()

        mapRenderer.onLocationSelected = onLocationSelected
    }

    @objc
    func handleLongPress(
        _ gesture: UILongPressGestureRecognizer
    ) {
        guard gesture.state == .began else {
            return
        }

        guard let mapView = gesture.view as? MKMapView else {
            return
        }

        let point = gesture.location(in: mapView)

        let coordinate = mapView.convert(
            point,
            toCoordinateFrom: mapView
        )

        onLongPress(coordinate)
    }

    func mapView(
        _ mapView: MKMapView,
        rendererFor overlay: MKOverlay
    ) -> MKOverlayRenderer {
        
        return polygonRenderer.renderer(
            for: overlay,
            fillColorHex: settingsService.mapFillColorHex
        )
    }
    
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        guard annotation is LocationAnnotation else {
            return nil
        }

        return mapRenderer.makeView(
            for: annotation,
            in: mapView
        )
    }
    
    func mapView(
        _ mapView: MKMapView,
        didSelect view: MKAnnotationView
    ) {
        guard let annotation = view.annotation as? LocationAnnotation else {
            return
        }

        mapRenderer.handleSelection(
            of: annotation
        )
    }
    func showUserLocation(
        _ coordinate: CLLocationCoordinate2D,
        on mapView: MKMapView
    ) {
        guard lastUserLocation == nil else {
            return
        }

        lastUserLocation = coordinate

        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )

        mapView.setRegion(
            region,
            animated: true
        )
    }
}
