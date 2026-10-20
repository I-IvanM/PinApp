//
//  LocationType.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation

enum LocationType: Codable {
    case city(CityVisitData)
    case mountain(MountainVisitData)
    case point
}
