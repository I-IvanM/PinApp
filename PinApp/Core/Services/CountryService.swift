//
//  CountryService.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation

final class CountryService {

    private let repository: CountryRepository

    init(repository: CountryRepository) {
        self.repository = repository
    }

    func fetchCountry(by countryID: String) throws -> Country? {
        return try repository.fetch(countryID: countryID)
    }

    func fetchAllCountries() throws -> [Country] {
        return try repository.fetchAll()
    }

    func plusPin(for countryID: String) throws {
        guard let country = try repository.fetch(countryID: countryID) else {
            return
        }

        let newPinCount = country.countryPinCount + 1

        try repository.setPinCount(
            newPinCount,
            for: countryID
        )
    }

    func minusPin(for countryID: String) throws {
        guard let country = try repository.fetch(countryID: countryID) else {
            return
        }

        let newPinCount = max(0, country.countryPinCount - 1)

        try repository.setPinCount(
            newPinCount,
            for: countryID
        )
    }

    func setPinCount(_ countryPinCount: Int, for countryID: String) throws {
        let validPinCount = max(0, countryPinCount)

        try repository.setPinCount(
            validPinCount,
            for: countryID
        )
    }
    
    func fetchVisitedCountries() throws -> [Country] {
        let countries = try repository.fetchAll()
        return countries.filter { $0.countryPinCount > 0 && $0.countryID != "XZ" }
    }
}
