//
//  StatisticsService.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation

final class StatisticsService {

    private let countryService: CountryService
    private let locationService: LocationService

    init(
        countryService: CountryService,
        locationService: LocationService
    ) {
        self.countryService = countryService
        self.locationService = locationService
    }

    func calculate() throws -> StatisticsValues {
        let countries = try countryService.fetchAllCountries()
        let locations = try locationService.fetchAll()

        var statistics = StatisticsValues(
            countryCount: 0,
            visitedCountryCount: 0,
            africaCount: 0,
            africaVisitedCount: 0,
            antarcticaVisitedCount: 0,
            asiaCount: 0,
            asiaVisitedCount: 0,
            europeCount: 0,
            europeVisitedCount: 0,
            northAmericaCount: 0,
            northAmericaVisitedCount: 0,
            southAmericaCount: 0,
            southAmericaVisitedCount: 0,
            oceaniaCount: 0,
            oceaniaVisitedCount: 0,
            visitedCountries: [],
            pointCount: 0,
            cityCount: 0,
            mountainCount: 0
        )

        calculateCountryStatistics(
            countries: countries,
            statistics: &statistics
        )

        calculateLocationStatistics(
            locations: locations,
            statistics: &statistics
        )

        return statistics
    }

    // MARK: - Private

    private func calculateCountryStatistics(
        countries: [Country],
        statistics: inout StatisticsValues
    ) {
        for country in countries {
            let isVisited = country.countryPinCount > 0

            switch country.countryID {
            case "XZ":
                continue

            case "AQ":
                if isVisited {
                    statistics.antarcticaVisitedCount = 1
                }

                continue

            default:
                break
            }

            statistics.countryCount += 1

            if isVisited {
                statistics.visitedCountryCount += 1
                statistics.visitedCountries.append(country)
            }

            switch country.continent {
            case "Africa":
                statistics.africaCount += 1

                if isVisited {
                    statistics.africaVisitedCount += 1
                }

            case "Asia":
                statistics.asiaCount += 1

                if isVisited {
                    statistics.asiaVisitedCount += 1
                }

            case "Europe":
                statistics.europeCount += 1

                if isVisited {
                    statistics.europeVisitedCount += 1
                }

            case "North America":
                statistics.northAmericaCount += 1

                if isVisited {
                    statistics.northAmericaVisitedCount += 1
                }

            case "South America":
                statistics.southAmericaCount += 1

                if isVisited {
                    statistics.southAmericaVisitedCount += 1
                }

            case "Oceania":
                statistics.oceaniaCount += 1

                if isVisited {
                    statistics.oceaniaVisitedCount += 1
                }

            default:
                break
            }
        }
    }

    private func calculateLocationStatistics(
        locations: [Location],
        statistics: inout StatisticsValues
    ) {
        for location in locations {
            switch location.type {
            case .point:
                statistics.pointCount += 1

            case .city:
                statistics.cityCount += 1

            case .mountain:
                statistics.mountainCount += 1
            }
        }
    }
}
