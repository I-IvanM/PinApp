//
//  OverlayFactory.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import MapKit
import SwiftUI
import UIKit

final class OverlayFactory {

    func makeCountryRenderer(
        for overlay: MKMultiPolygon,
        fillColorHex: String
    ) -> MKMultiPolygonRenderer {
        let renderer = MKMultiPolygonRenderer(
            multiPolygon: overlay
        )

        let fillColor = Color(hex: fillColorHex) ?? .blue

        renderer.fillColor = UIColor(fillColor).withAlphaComponent(0.4)
        renderer.strokeColor = .black
        renderer.lineWidth = 1.5

        return renderer
    }
}
