//
//  Database.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation
import SwiftData

final class Database {

    let container: ModelContainer

    init() throws {

        container = try ModelContainer(
            for:
                SwiftDataCity.self,
                SwiftDataLocation.self,
                SwiftDataCountry.self,
                SwiftDataMountain.self,
                SwiftDataPhoto.self
        )

        let context = ModelContext(container)

        try seedCountriesIfNeeded(context: context)
    }

    // MARK: - Country Seeding

    private func seedCountriesIfNeeded(context: ModelContext) throws {

        let descriptor = FetchDescriptor<SwiftDataCountry>()

        let countries = try context.fetch(descriptor)

        guard countries.isEmpty else {
            return
        }

        guard let url = Bundle.main.url(
            forResource: "Countries",
            withExtension: "json"
        ) else {
            throw DatabaseError.countriesFileNotFound
        }

        let data = try Data(contentsOf: url)

        let countriesData = try JSONDecoder().decode(
            [CountrySeedData].self,
            from: data
        )

        for countryData in countriesData {

            let country = SwiftDataCountry(
                countryID: countryData.countryID,
                countryName: countryData.name,
                countryPinCount: 0,
                continent: countryData.continent
            )

            context.insert(country)
        }

        try context.save()
    }
}

// MARK: - Country Seed Data

private struct CountrySeedData: Decodable {
    let countryID: String
    let name: String
    let continent: String
}

// MARK: - Database Error

private enum DatabaseError: Error {
    case countriesFileNotFound
}
