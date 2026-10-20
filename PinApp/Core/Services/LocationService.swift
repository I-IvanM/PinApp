//
//  LocationService.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation

final class LocationService {

    private let locationRepository: LocationRepository
    private let updateService: UpdateService
    private let countryService: CountryService
    private let cityService: CityService
    private let mountainService: MountainService

    init(
        locationRepository: LocationRepository,
        updateService: UpdateService,
        countryService: CountryService,
        cityService: CityService,
        mountainService: MountainService
    ) {
        self.locationRepository = locationRepository
        self.updateService = updateService
        self.countryService = countryService
        self.cityService = cityService
        self.mountainService = mountainService
        
    }
    
    func plusPin(for id: UUID) throws {
        guard let location = try locationRepository.fetch(id: id) else {
            return
        }

        let newPinCount = location.pinCount + 1

        var updatedLocation = location
        updatedLocation.pinCount = newPinCount

        try locationRepository.save(updatedLocation)
        updateService.notifyStatisticsUpdate()
    }

    func minusPin(for id: UUID) throws {
        guard let location = try locationRepository.fetch(id: id) else {
            return
        }

        let newPinCount = max(0, location.pinCount - 1)

        var updatedLocation = location
        updatedLocation.pinCount = newPinCount

        try locationRepository.save(updatedLocation)
        updateService.notifyStatisticsUpdate()
    }
    
    func saveLocation(_ location: Location) throws {

        var preparedLocation = location
        
        preparedLocation.coordinate = roundedTo(preparedLocation.coordinate, 6)

        switch preparedLocation.type {
        case.city(var cityVisitData):
            cityVisitData.cityCenterCoordinate = roundedTo(cityVisitData.cityCenterCoordinate, 3)
            preparedLocation.type = .city(cityVisitData)
        case.mountain(var mountainVisitData):
            mountainVisitData.mountainCoordinate = roundedTo(mountainVisitData.mountainCoordinate, 4)
            preparedLocation.type = .mountain(mountainVisitData)
        case.point:
            break
        }
        
        try locationRepository.save(preparedLocation)
        updateService.notifyMapUpdate()
        updateService.notifyPinListUpdate()
        updateService.notifyStatisticsUpdate()
    }
    
    func fetch(id: UUID) throws -> Location? {

        return try locationRepository.fetch(id: id)

    }
    
    func fetchAll() throws -> [Location] {

        return try locationRepository.fetchAll()

    }
    
    func delete(id: UUID) throws {
        let currrentLocation: Location = try fetch(id: id)!
        
        try countryService.minusPin(for: currrentLocation.countryID)
        
        switch currrentLocation.type {

        case .city(let cityVisitData):
            try cityService.minusPin(for: cityVisitData.cityCenterCoordinate)

        case .mountain(let mountainVisitData):
            try mountainService.minusPin(for: mountainVisitData.mountainCoordinate)

        case .point:
            break
        }
        
        try locationRepository.delete(id: id)
        updateService.notifyMapUpdate()
        updateService.notifyPinListUpdate()
        updateService.notifyStatisticsUpdate()
    }
    
    // MARK: - Private

    private func roundedTo(_ coordinate: Coordinate, _ to: Int) -> Coordinate {
        let roundedCoordinate = Coordinate(
            latitude: (coordinate.latitude * pow(10, Double(to))).rounded() / pow(10, Double(to)),
            longitude: (coordinate.longitude * pow(10, Double(to))).rounded() / pow(10, Double(to))
        )
        return roundedCoordinate
    }

}
