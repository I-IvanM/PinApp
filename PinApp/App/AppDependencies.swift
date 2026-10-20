//
//  AppDependencies.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation
import SwiftData

final class AppDependencies {
    
    let database: Database
    
    let cityRepository: CityRepository
    let countryRepository: CountryRepository
    let locationRepository: LocationRepository
    let mountainRepository: MountainRepository
    let photoRepository: PhotoRepository
    
    let cityService: CityService
    let countryService: CountryService
    let creationService: CreationService
    let fromPhotoCoordinatesImportService: FromPhotoCoordinatesImportService
    let locationService: LocationService
    let mountainService: MountainService
    let reverseGeocodingService: ReverseGeocodingService
    let searchService: SearchService
    let settingsService: SettingsService
    let statisticsService: StatisticsService
    let updateService: UpdateService
    
    let networkMonitor: NetworkMonitor
    
    let photoLibraryManager: PhotoLibraryManager
    
    let polygonIndex: PolygonIndex
    let polygonSearch: PolygonSearch
    let countrySearch: CountrySearch

    
    
    init() {
        
        database = try! Database()
        
        let context = database.container.mainContext
        
        cityRepository = SwiftDataCityRepository(context: context)
        countryRepository = SwiftDataCountryRepository(context: context)
        locationRepository = SwiftDataLocationRepository(context: context)
        mountainRepository = SwiftDataMountainRepository(context: context)
        photoRepository = SwiftDataPhotoRepository(context: context)
        
        let networkMonitor = NetworkMonitor()
        self.networkMonitor = networkMonitor

        self.updateService = UpdateService()
        self.settingsService = SettingsService()
        
        self.photoLibraryManager = PhotoLibraryManager()

        cityService = CityService(repository: cityRepository)
        countryService = CountryService(repository: countryRepository)
        mountainService = MountainService(repository: mountainRepository)

        searchService = SearchService()

        locationService = LocationService(locationRepository: locationRepository, updateService: updateService, countryService: countryService, cityService: cityService, mountainService: mountainService)

        statisticsService = StatisticsService(countryService: countryService, locationService: locationService)

        creationService = CreationService(locationService: locationService, cityService: cityService, mountainService: mountainService, searchService: searchService, countryService: countryService, settingsService: settingsService)

        let polygonLoader = PolygonLoader()
        
        let polygonIndex = try! polygonLoader.loadIndex()
        self.polygonIndex = polygonIndex

        let pointInPolygon = PointInPolygon()

        self.countrySearch = CountrySearch(polygonIndex: polygonIndex, pointInPolygon: pointInPolygon)

        self.polygonSearch = PolygonSearch(polygonIndex: polygonIndex)

        self.reverseGeocodingService = ReverseGeocodingService(networkMonitor: networkMonitor, countrySearch: countrySearch)
        
        self.fromPhotoCoordinatesImportService = FromPhotoCoordinatesImportService(photoLibraryManager: photoLibraryManager, locationService: locationService, creationService: creationService, reverseGeocodingService: reverseGeocodingService)
    }
    
}
