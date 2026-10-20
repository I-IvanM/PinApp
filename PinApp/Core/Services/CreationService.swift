//
//  CreationService.swift
//  PinApp
//
//  Created by I_IvanM on 14.08.2026.
//

import Foundation

final class CreationService {

    private let locationService: LocationService
    private let cityService: CityService
    private let mountainService: MountainService
    private let searchService: SearchService
    private let countryService: CountryService
    private let settingsService: SettingsService

    init(
        locationService: LocationService,
        cityService: CityService,
        mountainService: MountainService,
        searchService: SearchService,
        countryService: CountryService,
        settingsService: SettingsService
    ) {
        self.locationService = locationService
        self.cityService = cityService
        self.mountainService = mountainService
        self.searchService = searchService
        self.countryService = countryService
        self.settingsService = settingsService
    }

    func create(from allValues: AllValues) async throws -> Location{
        
        // MARK: checks
        
        guard let coordinate = allValues.coordinate else {
            throw NSError(
                domain: "CreationService",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Coordinate is missing in AllValues."
                ]
            )
        }
        
        guard let countryID = allValues.countryID else {
            throw NSError(
                domain: "CreationService",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey: "countryID is missing in AllValues."
                ]
            )
        }

        var isNew: Bool = true
        var oldLocation: Location?

        if let id = allValues.id {
            isNew = false

            oldLocation = try locationService.fetch(id: id)

            if oldLocation == nil {
                isNew = true
            }
        }
        try countryService.plusPin(for: countryID)

        // MARK: Creating location

        var newLocation = Location(
            id: allValues.id ?? UUID(),
            title: allValues.title ?? "New pin",
            coordinate: coordinate,
            type: .point,
            note: allValues.note,
            tags: allValues.tags,
            photoIDs: allValues.photoIDs,
            countryID: allValues.countryID ?? "XZ",
            date: allValues.date ?? Date(),
            color: allValues.color ?? settingsService.defaultPinColorHex,
            pinCount: allValues.pinCount ?? 1
        )

        switch allValues.type {

        case .city:
            try await createCity(
                from: allValues,
                newLocation: &newLocation,
                oldLocation: oldLocation,
                isNew: isNew,
                countryID: countryID
            )

        case .mountain:
            try await createMountain(
                from: allValues,
                newLocation: &newLocation,
                oldLocation: oldLocation,
                isNew: isNew,
                countryID: countryID
            )

        case .point, .none:
            newLocation.type = .point

            if !isNew {
                try removeOldObject(
                    from: oldLocation
                )
            }
        }

        try locationService.saveLocation(newLocation)

        print(newLocation)
        
        return newLocation
    }

    // MARK: - private

    private func createCity(
        from allValues: AllValues,
        newLocation: inout Location,
        oldLocation: Location?,
        isNew: Bool,
        countryID: String
    ) async throws {

        guard
            let cityName = allValues.cityName
        else {
            return
        }

        let searchQuery = "\(cityName) \(countryID)"

        let cityCenterCoordinate = await searchCoordinate(
            query: searchQuery, near: newLocation.coordinate
        )

        let roundedCityCenterCoordinate = roundedTo(
            cityCenterCoordinate, 3
        )


        if var city = try cityService.fetchCity(
            by: roundedCityCenterCoordinate
        ) {

            if isNew {
                city.cityPinCount += 1
            }

            if let cityName = allValues.cityName {
                city.cityName = cityName
            }

            try cityService.saveCity(city)

        } else {

            guard let cityName = allValues.cityName else {
                return
            }

            let city = City(
                cityName: cityName,
                cityCenterCoordinate: roundedCityCenterCoordinate,
                cityPinCount: 1
            )

            try cityService.saveCity(city)

            if !isNew {
                try removeOldObject(
                    from: oldLocation
                )
            }
        }


        newLocation.type = .city(
            CityVisitData(
                cityCenterCoordinate: roundedCityCenterCoordinate,
                address: allValues.address ?? ""
            )
        )
    }


    private func createMountain(
        from allValues: AllValues,
        newLocation: inout Location,
        oldLocation: Location?,
        isNew: Bool,
        countryID: String
    ) async throws {

        guard
            let title = allValues.title
        else {
            return
        }

        let searchQuery = "\(title) \(countryID)"

        let mountainCoordinate = await searchCoordinate(
            query: searchQuery, near: newLocation.coordinate
        )

        let roundedMountainCoordinate = roundedTo(
            mountainCoordinate, 4
        )

        if var mountain = try mountainService.fetchMountain(
            by: roundedMountainCoordinate
        ) {

            if isNew {
                mountain.mountainPinCount += 1
            }

            if let mountainName = allValues.mountainName {
                mountain.mountainName = mountainName
            }

            if let height = allValues.height {
                mountain.height = height
            }

            try mountainService.saveMountain(mountain)

        } else {

            guard let mountainName = allValues.mountainName else {
                return
            }

            let mountain = Mountain(
                mountainName: mountainName,
                height: allValues.height,
                mountainCoordinate: roundedMountainCoordinate,
                mountainPinCount: 1
            )

            try mountainService.saveMountain(mountain)

            if !isNew {
                try removeOldObject(
                    from: oldLocation
                )
            }
        }

        newLocation.type = .mountain(
            MountainVisitData(
                mountainCoordinate: roundedMountainCoordinate,
                achievedHeight: allValues.achievedHeight ?? 0
            )
        )
    }



    private func searchCoordinate(
        query: String,
        near coordinate: Coordinate
    ) async -> Coordinate {

        if let coordinate = await searchService.search(
            query: query,
            near: coordinate
        ) {
            return coordinate
        }

        if let coordinate = await searchService.search(
            query: query,
            near: coordinate
        ) {
            return coordinate
        }

        return coordinate
    }
    

    private func removeOldObject(from oldLocation: Location?) throws {

        guard let oldLocation else {
            return
        }
        
        try countryService.minusPin(for: oldLocation.countryID)

        switch oldLocation.type {

        case .city(let cityVisitData):
            try cityService.minusPin(
                for: cityVisitData.cityCenterCoordinate
            )

        case .mountain(let mountainVisitData):
            try mountainService.minusPin(
                for: mountainVisitData.mountainCoordinate
            )

        case .point:
            break
        }
    }


    private func roundedTo(_ coordinate: Coordinate, _ to: Int) -> Coordinate {
        let roundedCoordinate = Coordinate(
            latitude: (coordinate.latitude * pow(10, Double(to))).rounded() / pow(10, Double(to)),
            longitude: (coordinate.longitude * pow(10, Double(to))).rounded() / pow(10, Double(to))
        )
        return roundedCoordinate
    }
}
