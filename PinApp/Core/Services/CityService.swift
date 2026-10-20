//
//  CityService.swift
//  PinApp
//
//  Created by I_IvanM on 14.08.2026.
//

import Foundation

final class CityService {

    private let repository: CityRepository

    init(repository: CityRepository) {
        self.repository = repository
    }
    
    func plusPin(for cityCenterCoordinate: Coordinate) throws {
        guard let city = try repository.fetch(
            cityCenterCoordinate: cityCenterCoordinate
        ) else {
            return
        }

        var updatedCity = city
        updatedCity.cityPinCount += 1

        try repository.save(updatedCity)
    }

    func minusPin(for cityCenterCoordinate: Coordinate) throws {
        guard let city = try repository.fetch(
            cityCenterCoordinate: cityCenterCoordinate
        ) else {
            return
        }

        var updatedCity = city
        updatedCity.cityPinCount = max(0, updatedCity.cityPinCount - 1)
        if updatedCity.cityPinCount == 0 {
            try repository.delete(cityCenterCoordinate)
            return
        }
        try repository.save(updatedCity)
    }

    func fetchAllCities() throws -> [City] {
        return try repository.fetchAll()
    }

    func fetchCity(by cityCenterCoordinate: Coordinate) throws -> City? {
        return try repository.fetch(
            cityCenterCoordinate: cityCenterCoordinate
        )
    }

    func saveCity(_ city: City) throws {
        try repository.save(city)
    }

    func deleteCity(at cityCenterCoordinate: Coordinate) throws {
        try repository.delete(cityCenterCoordinate)
    }
}
