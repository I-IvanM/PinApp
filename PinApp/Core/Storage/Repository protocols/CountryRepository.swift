//
//  CountryRepository.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation

protocol CountryRepository {
    
    func fetchAll()throws -> [Country]

    func fetch(countryID: String)throws -> Country?

    func save(_ country: Country)throws

    func delete(_ countryID: String)throws

}
