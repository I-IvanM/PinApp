//
//  SwiftDataCountryRepository.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import SwiftData

final class SwiftDataCountryRepository: CountryRepository {
    
    private let context: ModelContext
    init(context: ModelContext) {self.context = context}
    
    func fetchAll()throws -> [Country]{
        let descriptor = FetchDescriptor<SwiftDataCountry>()
        let swiftDataCountries = try context.fetch(descriptor)
        return swiftDataCountries.map { swiftDataCountry in makeCountry(from: swiftDataCountry)}
    }

    func fetch(countryID: String)throws -> Country? {
        let descriptor = FetchDescriptor<SwiftDataCountry>(
                predicate: #Predicate {
                    $0.countryID == countryID
                }
            )
        
        guard let swiftDataCountry = try context.fetch(descriptor).first else {
            return nil
        }
        
        return makeCountry(from: swiftDataCountry)
    }

    func setPinCount(_ countryPinCount: Int, for countryID: String) throws {

        let descriptor = FetchDescriptor<SwiftDataCountry>(
            predicate: #Predicate {
                $0.countryID == countryID
            }
        )

        guard let country = try context.fetch(descriptor).first else {
            return
        }

        country.countryPinCount = countryPinCount

        try context.save()
    }
    
    // MARK: Сonverters Model <-> SwiftDataModel – Private
    
    private func makeSwiftDataCountry(from country: Country) -> SwiftDataCountry {
        let swiftDataCountry = SwiftDataCountry(
            countryID: country.countryID,
            countryName: country.countryName,
            countryPinCount: country.countryPinCount,
            continent: country.continent
        )
        return swiftDataCountry
    }
    
    private func makeCountry(from swiftDataCountry: SwiftDataCountry) -> Country {
        let country = Country(
            countryID: swiftDataCountry.countryID,
            countryName: swiftDataCountry.countryName,
            countryPinCount: swiftDataCountry.countryPinCount,
            continent: swiftDataCountry.continent
        )
        return country
    }

}
