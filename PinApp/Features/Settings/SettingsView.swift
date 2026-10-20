//
//  SettingsView.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import SwiftUI
import MapKit

struct SettingsView: View {
    let dependencies: AppDependencies

    var body: some View {
        ZStack(alignment: .top) {
            background

                VStack(alignment: .leading, spacing: 20) {
                    pinColorSection
                    mapFillColorSection
                    mapStyleSection
                    PhotoImportView(dependencies: dependencies)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    private var background: some View {
        Color("SettingsBackground")
            .ignoresSafeArea()
    }

    private var pinColorSection: some View {
        settingsSection {
            HStack {
                Label(
                    "Pin Color",
                    systemImage: "mappin.circle.fill"
                )

                Spacer()

                ColorPicker(
                    "",
                    selection: pinColorBinding,
                    supportsOpacity: false
                )
                .labelsHidden()
            }
        }
    }

    private var mapFillColorSection: some View {
        settingsSection {
            HStack {
                Label(
                    "Map Fill Color",
                    systemImage: "paintpalette.fill"
                )

                Spacer()

                ColorPicker(
                    "",
                    selection: mapFillColorBinding,
                    supportsOpacity: false
                )
                .labelsHidden()
            }
        }
    }

    private var mapStyleSection: some View {
        settingsSection {
            VStack(alignment: .leading, spacing: 14) {
                Label(
                    "Map Type",
                    systemImage: "map.fill"
                )

                HStack(spacing: 10) {
                    mapStyleButton(
                        style: .standard,
                        title: "Standard"
                    )

                    mapStyleButton(
                        style: .satellite,
                        title: "Satellite"
                    )

                    mapStyleButton(
                        style: .hybrid,
                        title: "Hybrid"
                    )
                }
            }
        }
    }

    private func settingsSection<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity)
            .glassBackground()
    }

    private func mapStyleButton(
        style: MapStyle,
        title: String
    ) -> some View {
        let isSelected = dependencies.settingsService.mapStyle == style

        return Button {
            dependencies.settingsService.mapStyle = style
        } label: {
            VStack(spacing: 8) {
                MapPreview(style: style)
                    .frame(height: 100)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )
                    .allowsHitTesting(false)

                /*
                Text(title)
                    .font(.subheadline)
                    .fontWeight(
                        isSelected
                        ? .semibold
                        : .regular
                    )
                    .foregroundStyle(.primary)
                 */
            }
            .frame(maxWidth: .infinity)
            .padding(6)
            .contentShape(
                RoundedRectangle(cornerRadius: 16)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected
                        ? Color.primary
                        : Color.clear,
                        lineWidth: 2
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private var pinColorBinding: Binding<Color> {
        Binding(
            get: {
                Color(
                    hex: dependencies.settingsService.defaultPinColorHex
                ) ?? .accentColor
            },
            set: { color in
                dependencies.settingsService.defaultPinColorHex = color.toHex()
            }
        )
    }

    private var mapFillColorBinding: Binding<Color> {
        Binding(
            get: {
                Color(
                    hex: dependencies.settingsService.mapFillColorHex
                ) ?? .accentColor
            },
            set: { color in
                dependencies.settingsService.mapFillColorHex = color.toHex()
            }
        )
    }
}

private struct MapPreview: UIViewRepresentable {
    let style: MapStyle

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()

        mapView.isUserInteractionEnabled = false
        mapView.isMultipleTouchEnabled = false
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsBuildings = true
        mapView.pointOfInterestFilter = .includingAll

        let coordinate = CLLocationCoordinate2D(
            latitude: 48.14874,
            longitude: 11.57432
        )

        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.085,
                longitudeDelta: 0.085
            )
        )

        mapView.setRegion(
            region,
            animated: false
        )

        mapView.mapType = style.mapKitMapType

        return mapView
    }

    func updateUIView(
        _ mapView: MKMapView,
        context: Context
    ) {
        mapView.mapType = style.mapKitMapType
    }
}


private extension View {
    @ViewBuilder
    func glassBackground() -> some View {
        if #available(iOS 26, *) {
            self
                .glassEffect(
                    .regular,
                    in: .rect(cornerRadius: 22)
                )
        } else {
            self
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(
                        cornerRadius: 22
                    )
                )
        }
    }
}
