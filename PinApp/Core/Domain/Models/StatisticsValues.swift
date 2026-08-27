//
//  Statistics.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation

struct Statistics {

    var countryCount: Int
    var visitedCountryCount: Int

    
    var africaCount: Int
    var africaVisitedCount: Int
    
    var antarcticaCount: Int = 1
    var antarcticaVisitedCount: Int
    
    var asiaCount: Int
    var asiaVisitedCount: Int
    
    var europeCount: Int
    var europeVisitedCount: Int
    
    var northAmericaCount: Int
    var northAmericaVisitedCount: Int
    
    var southAmericaCount: Int
    var southAmericaVisitedCount: Int
    
    var oceaniaCount: Int
    var oceaniaVisitedCount: Int

    var visitedCountries: [CountryStatistics]

    var pointCount: Int
    var cityCount: Int
    var mountainCount: Int
}

struct CountryStatistics {

    var countryID: String
    var countryName: String
    var pinCount: Int
}
