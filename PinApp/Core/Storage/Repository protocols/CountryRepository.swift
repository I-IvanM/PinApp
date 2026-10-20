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

    func setPinCount(_ pinCount: Int, for countryID: String)throws

}
