//
//  PolygonRenderer.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import MapKit

final class PolygonRenderer {

    private let overlayFactory: OverlayFactory

    private var renderedOverlays: [MKMultiPolygon] = []

    init(overlayFactory: OverlayFactory = OverlayFactory()) {
        self.overlayFactory = overlayFactory
    }

    func render(
        polygons: [MKMultiPolygon],
        on mapView: MKMapView
    ) {
        print("Rendering country polygons: \(polygons.count)")
        
        if !renderedOverlays.isEmpty {
            mapView.removeOverlays(renderedOverlays)
        }

        renderedOverlays = polygons

        for polygon in polygons {
            mapView.addOverlay(polygon)
        }
    }

    func renderer(
        for overlay: MKOverlay,
        fillColorHex: String
    ) -> MKOverlayRenderer {
        guard let polygon = overlay as? MKMultiPolygon else {
            return MKOverlayRenderer(overlay: overlay)
        }

        return overlayFactory.makeCountryRenderer(
            for: polygon,
            fillColorHex: fillColorHex
        )
    }
}
