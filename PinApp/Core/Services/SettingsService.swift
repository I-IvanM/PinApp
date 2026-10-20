//
//  SettingsService.swift
//  PinApp
//
//  Created by I_IvanM on 18.08.2026.
//

import Foundation
import Observation

@Observable
final class SettingsService {

    private let userDefaults: UserDefaults

    var defaultPinColorHex: String {
        didSet {
            userDefaults.set(
                defaultPinColorHex,
                forKey: Keys.defaultPinColorHex
            )
        }
    }

    var mapFillColorHex: String {
        didSet {
            userDefaults.set(
                mapFillColorHex,
                forKey: Keys.mapFillColorHex
            )
        }
    }

    var mapStyle: MapStyle {
        didSet {
            userDefaults.set(
                mapStyle.rawValue,
                forKey: Keys.mapStyle
            )
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if let value = userDefaults.string(
            forKey: Keys.defaultPinColorHex
        ) {
            self.defaultPinColorHex = value
        } else {
            self.defaultPinColorHex = "#FF0000"
        }

        if let value = userDefaults.string(
            forKey: Keys.mapFillColorHex
        ) {
            self.mapFillColorHex = value
        } else {
            self.mapFillColorHex = "#FFFFFF"
        }

        if let rawValue = userDefaults.string(
            forKey: Keys.mapStyle
        ),
           let style = MapStyle(rawValue: rawValue) {
            self.mapStyle = style
        } else {
            self.mapStyle = .standard
        }
    }

    private enum Keys {
        static let defaultPinColorHex = "defaultPinColorHex"
        static let mapFillColorHex = "mapFillColorHex"
        static let mapStyle = "mapStyle"
    }
}
