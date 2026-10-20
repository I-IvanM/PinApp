//
//  Color+Extensions.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
    
    init?(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        
        guard hex.count == 6 || hex.count == 8 else {
            return nil
        }
        
        guard let value = UInt64(hex, radix: 16) else {
            return nil
        }
        
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
        
        if hex.count == 6 {
            red = Double((value >> 16) & 0xFF) / 255
            green = Double((value >> 8) & 0xFF) / 255
            blue = Double(value & 0xFF) / 255
            alpha = 1
        } else {
            red = Double((value >> 24) & 0xFF) / 255
            green = Double((value >> 16) & 0xFF) / 255
            blue = Double((value >> 8) & 0xFF) / 255
            alpha = Double(value & 0xFF) / 255
        }
        
        self.init(
            red: red,
            green: green,
            blue: blue,
            opacity: alpha
        )
    }
    func toHex() -> String {
        let resolvedColor = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        resolvedColor.getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )

        let redInt = Int(round(red * 255))
        let greenInt = Int(round(green * 255))
        let blueInt = Int(round(blue * 255))

        return String(
            format: "#%02X%02X%02X",
            redInt,
            greenInt,
            blueInt
        )
    }
}
