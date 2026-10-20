//
//  StatisticsWorldMap.swift
//  PinApp
//
//  Created by I_IvanM on 23.08.2026.
//

import Foundation
import SwiftUI
import MapKit

struct StatisticsWorldMap: View {

    let countryCount: Int
    let visitedCountryCount: Int
    let visitedCountries: [Country]

    let polygonSearch: PolygonSearch
    let settingsService: SettingsService

    var body: some View {
        ZStack {
            StatisticsWorldMapRepresentable(
                visitedCountries: visitedCountries,
                polygonSearch: polygonSearch,
                mapStyle: settingsService.mapStyle,
                fillColorHex: settingsService.mapFillColorHex
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 22)
            )
            

            Text("\(visitedCountryCount)/\(countryCount)")
                .font(
                    .system(
                        size: fontSize,
                        weight: .bold
                    )
                )
                .tracking(2)
                .foregroundStyle(.white)
                .shadow(
                    color: .black.opacity(0.6),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        }
        .frame(height: 240)
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    .white.opacity(0.35),
                    lineWidth: 1
                )
        }
        .modifier(StatisticsWorldMapGlass())
    }
    
    private var fontSize: Double {
        if visitedCountryCount <= 10 {
            return 100.0
        } else if visitedCountryCount <= 20 {
            return 90.0
        } else {
            return 70.0
        }
    }
}

// MARK: - Map

private struct StatisticsWorldMapRepresentable: UIViewRepresentable {

    let visitedCountries: [Country]
    let polygonSearch: PolygonSearch
    let mapStyle: MapStyle
    let fillColorHex: String

    func makeCoordinator() -> Coordinator {
        Coordinator(
            polygonRenderer: PolygonRenderer(),
            fillColorHex: fillColorHex
        )
    }

    func makeUIView(
        context: Context
    ) -> MKMapView {

        let mapView = MKMapView()

        mapView.delegate = context.coordinator

        mapView.isUserInteractionEnabled = false
        mapView.isMultipleTouchEnabled = false

        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsBuildings = false
        mapView.pointOfInterestFilter = .excludingAll

        mapView.mapType = mapStyle.mapKitMapType

        mapView.setRegion(
            worldRegion,
            animated: false
        )

        renderCountries(
            on: mapView,
            using: context.coordinator.polygonRenderer
        )

        return mapView
    }

    func updateUIView(
        _ mapView: MKMapView,
        context: Context
    ) {
        mapView.mapType = mapStyle.mapKitMapType

        context.coordinator.fillColorHex = fillColorHex

        mapView.removeOverlays(
            mapView.overlays
        )

        renderCountries(
            on: mapView,
            using: context.coordinator.polygonRenderer
        )
    }

    private func renderCountries(
        on mapView: MKMapView,
        using polygonRenderer: PolygonRenderer
    ) {
        let polygons = polygonSearch.search(
            countries: visitedCountries
        )

        polygonRenderer.render(
            polygons: polygons,
            on: mapView
        )
    }

    private var worldRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 35,
                longitude: -8
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 180,
                longitudeDelta: 360
            )
        )
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {

        let polygonRenderer: PolygonRenderer
        var fillColorHex: String

        init(
            polygonRenderer: PolygonRenderer,
            fillColorHex: String
        ) {
            self.polygonRenderer = polygonRenderer
            self.fillColorHex = fillColorHex
        }

        func mapView(
            _ mapView: MKMapView,
            rendererFor overlay: MKOverlay
        ) -> MKOverlayRenderer {
            polygonRenderer.renderer(
                for: overlay,
                fillColorHex: fillColorHex
            )
        }
    }
}

// MARK: - Glass

private struct StatisticsWorldMapGlass: ViewModifier {

    func body(
        content: Content
    ) -> some View {

        if #available(iOS 26, *) {
            content
                .glassEffect(
                    .regular,
                    in: .rect(cornerRadius: 22)
                )
        } else {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(
                        cornerRadius: 22
                    )
                )
        }
    }
}
