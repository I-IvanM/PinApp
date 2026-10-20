//
//  PinState.swift
//  PinApp
//
//  Created by I_IvanM on 05.09.2026.
//

import Foundation
import Combine

@MainActor
final class PinState: ObservableObject {

    // Dependencies

    let dependencies: AppDependencies
    let locationID: UUID?
    let initialCoordinate: Coordinate?

    // Main state

    @Published var allValues: AllValues

    // ext fields

    @Published var latitudeText: String
    @Published var longitudeText: String
    @Published var heightText: String
    @Published var achievedHeightText: String

    // Country selection

    @Published var countries: [Country] = []
    @Published var countrySearchText = ""
    @Published var isCountryListVisible = false

    // AutoFilled ?

    @Published var titleWasAutoFilled = false
    @Published var countryWasAutoFilled = false
    @Published var cityNameWasAutoFilled = false
    @Published var addressWasAutoFilled = false
    @Published var mountainNameWasAutoFilled = false

    // is in process ?

    private var isUpdatingCoordinateFields = false
    private var isApplyingAutomaticValues = false
    @Published var isLoading = true
    
    @Published var errorMessage: String?

    init(
        dependencies: AppDependencies,
        locationID: UUID? = nil,
        coordinate: Coordinate? = nil
    ) {
        self.dependencies = dependencies
        self.locationID = locationID
        self.initialCoordinate = coordinate

        let initialValues = AllValues(
            id: nil,
            title: "New pin",
            coordinate: nil,
            type: .point,
            note: nil,
            tags: nil,
            photoIDs: nil,
            countryID: nil,
            countryName: nil,
            countryPinCount: nil,
            date: Date(),
            color: dependencies.settingsService.defaultPinColorHex,
            pinCount: 1,
            cityName: nil,
            cityCenterCoordinate: nil,
            cityPinCount: nil,
            address: nil,
            mountainName: nil,
            height: nil,
            mountainCoordinate: nil,
            mountainPinCount: 0,
            achievedHeight: nil
        )

        self.allValues = initialValues
        self.latitudeText = coordinate.map { String($0.latitude) } ?? ""
        self.longitudeText = coordinate.map { String($0.longitude) } ?? ""
        self.heightText = ""
        self.achievedHeightText = ""
    }

    // MARK: - Preparation

    func prepare() async {
        isLoading = true
        errorMessage = nil

        do {
            countries = try dependencies.countryService
                .fetchAllCountries()
                .sorted {
                    $0.countryName.localizedCaseInsensitiveCompare(
                        $1.countryName
                    ) == .orderedAscending
                }

            if let locationID {
                allValues.id = locationID

                if let location = try dependencies.locationService.fetch(
                    id: locationID
                ) {
                    loadLocation(location)

                    isLoading = false

                    synchronizeCoordinateTextFields()
                    synchronizeTypeSpecificTextFields()

                    if allValues.coordinate != nil {
                        await reverseGeocodeCurrentCoordinate()
                    }

                    return
                }
            }

            if let initialCoordinate {
                setInitialCoordinate(initialCoordinate)
            }

            isLoading = false

            if allValues.coordinate != nil {
                await reverseGeocodeCurrentCoordinate()
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    private func loadLocation(_ location: Location) {
        allValues.id = location.id
        allValues.title = location.title
        allValues.coordinate = location.coordinate
        allValues.note = location.note
        allValues.tags = location.tags
        allValues.photoIDs = location.photoIDs
        allValues.countryID = location.countryID
        allValues.date = location.date
        allValues.color = location.color
        allValues.pinCount = location.pinCount

        switch location.type {
        case .point:
            allValues.type = .point

        case .city(let cityVisitData):
            allValues.type = .city
            allValues.cityCenterCoordinate =
                cityVisitData.cityCenterCoordinate
            allValues.address = cityVisitData.address

            loadCity(
                at: cityVisitData.cityCenterCoordinate
            )

        case .mountain(let mountainVisitData):
            allValues.type = .mountain
            allValues.mountainCoordinate =
                mountainVisitData.mountainCoordinate
            allValues.achievedHeight =
                mountainVisitData.achievedHeight

            loadMountain(
                at: mountainVisitData.mountainCoordinate
            )
        }

        loadCountry(
            with: location.countryID
        )
    }

    private func setInitialCoordinate(
        _ coordinate: Coordinate
    ) {
        allValues.coordinate = coordinate
        synchronizeCoordinateTextFields()
    }

    private func loadCity(
        at coordinate: Coordinate
    ) {
        do {
            guard let city = try dependencies.cityService.fetchCity(
                by: coordinate
            ) else {
                return
            }

            allValues.cityName = city.cityName
            allValues.cityCenterCoordinate =
                city.cityCenterCoordinate
            allValues.cityPinCount = city.cityPinCount
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadMountain(
        at coordinate: Coordinate
    ) {
        do {
            guard let mountain = try dependencies.mountainService.fetchMountain(
                by: coordinate
            ) else {
                return
            }

            allValues.mountainName = mountain.mountainName
            allValues.height = mountain.height
            allValues.mountainCoordinate =
                mountain.mountainCoordinate
            allValues.mountainPinCount =
                mountain.mountainPinCount

            synchronizeTypeSpecificTextFields()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadCountry(
        with countryID: String
    ) {
        do {
            guard let country = try dependencies.countryService.fetchCountry(
                by: countryID
            ) else {
                return
            }

            allValues.countryID = country.countryID
            allValues.countryName = country.countryName
            allValues.countryPinCount = country.countryPinCount
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Coordinates

    func updateCoordinateFromTextFields() {
        guard !isUpdatingCoordinateFields else {
            return
        }

        guard let latitude = Double(
            latitudeText.replacingOccurrences(
                of: ",",
                with: "."
            )
        ),
        let longitude = Double(
            longitudeText.replacingOccurrences(
                of: ",",
                with: "."
            )
        ) else {
            return
        }

        guard (-90...90).contains(latitude),
              (-180...180).contains(longitude) else {
            return
        }

        let newCoordinate = Coordinate(
            latitude: latitude,
            longitude: longitude,
            altitude: allValues.coordinate?.altitude
        )

        guard coordinatesAreDifferent(
            allValues.coordinate,
            newCoordinate
        ) else {
            return
        }

        allValues.coordinate = newCoordinate

        Task {
            await reverseGeocodeCurrentCoordinate()
        }
    }

    func synchronizeCoordinateTextFields() {
        guard let coordinate = allValues.coordinate else {
            latitudeText = ""
            longitudeText = ""
            return
        }

        isUpdatingCoordinateFields = true

        latitudeText = String(coordinate.latitude)
        longitudeText = String(coordinate.longitude)

        isUpdatingCoordinateFields = false
    }

    private func coordinatesAreDifferent(
        _ first: Coordinate?,
        _ second: Coordinate
    ) -> Bool {
        guard let first else {
            return true
        }

        return first.latitude != second.latitude ||
            first.longitude != second.longitude ||
            first.altitude != second.altitude
    }

    // MARK: - Reverse Geocoding

    private func reverseGeocodeCurrentCoordinate() async {
        guard let coordinate = allValues.coordinate else {
            return
        }

        let result = await dependencies.reverseGeocodingService
            .reverseGeocode(coordinate: coordinate)

        applyReverseGeocodingResult(result)
    }

    private func applyReverseGeocodingResult(
        _ result: (
            countryID: String?,
            title: String?,
            cityName: String?,
            address: String?
        )
    ) {
        isApplyingAutomaticValues = true

        if let countryID = result.countryID,
           canAutomaticallyFillCountry() {

            allValues.countryID = countryID
            countryWasAutoFilled = true

            loadCountry(with: countryID)
        }

        if let title = result.title {
            if canAutomaticallyFillTitle() {
                allValues.title = title
                titleWasAutoFilled = true
            }

            if canAutomaticallyFillMountainName() {
                allValues.mountainName = title
                mountainNameWasAutoFilled = true
            }
        }

        if let cityName = result.cityName,
           canAutomaticallyFillCityName() {

            allValues.cityName = cityName
            cityNameWasAutoFilled = true
        }

        if let address = result.address,
           canAutomaticallyFillAddress() {

            allValues.address = address
            addressWasAutoFilled = true
        }

        isApplyingAutomaticValues = false
    }

    private func canAutomaticallyFillTitle() -> Bool {
        guard let title = allValues.title else {
            return true
        }

        return title.isEmpty ||
            title == "New pin" ||
            titleWasAutoFilled
    }

    private func canAutomaticallyFillCountry() -> Bool {
        guard let countryID = allValues.countryID else {
            return true
        }

        return countryID.isEmpty || countryWasAutoFilled
    }

    private func canAutomaticallyFillCityName() -> Bool {
        guard let cityName = allValues.cityName else {
            return true
        }

        return cityName.isEmpty || cityNameWasAutoFilled
    }

    private func canAutomaticallyFillAddress() -> Bool {
        guard let address = allValues.address else {
            return true
        }

        return address.isEmpty || addressWasAutoFilled
    }

    private func canAutomaticallyFillMountainName() -> Bool {
        guard let mountainName = allValues.mountainName else {
            return true
        }

        return mountainName.isEmpty || mountainNameWasAutoFilled
    }

    // MARK: - Country

    func selectCountry(
        _ country: Country
    ) {
        allValues.countryID = country.countryID
        allValues.countryName = country.countryName
        allValues.countryPinCount = country.countryPinCount

        countrySearchText = country.countryName
        countryWasAutoFilled = false
        isCountryListVisible = false
    }

    // MARK: - Type

    func synchronizeTypeSpecificTextFields() {
        guard allValues.type == .mountain else {
            heightText = ""
            achievedHeightText = ""
            return
        }

        if let height = allValues.height {
            heightText = String(height)
        } else {
            heightText = ""
        }

        if let achievedHeight = allValues.achievedHeight {
            achievedHeightText = String(achievedHeight)
        } else {
            achievedHeightText = ""
        }
    }

    // MARK: - Save

    func save() async throws {
        updateValuesFromVisibleFields()

        guard validateRequiredFields() else {
            return
        }

        let _ = try await dependencies.creationService.create(
            from: allValues
        )
    }

    // MARK: - Delete

    func delete() {
        guard let locationID else {
            return
        }

        do {
            try dependencies.locationService.delete(
                id: locationID
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Values

    private func updateValuesFromVisibleFields() {
        allValues.title = allValues.title ?? ""

        allValues.note = normalizedOptionalString(
            allValues.note
        )

        allValues.tags = normalizedTags(
            allValues.tags
        )

        if let height = Double(
            heightText.replacingOccurrences(
                of: ",",
                with: "."
            )
        ) {
            allValues.height = height
        } else if allValues.type == .mountain {
            allValues.height = nil
        }

        if let achievedHeight = Double(
            achievedHeightText.replacingOccurrences(
                of: ",",
                with: "."
            )
        ) {
            allValues.achievedHeight = achievedHeight
        } else if allValues.type == .mountain {
            allValues.achievedHeight = nil
        }
    }

    private func normalizedOptionalString(
        _ value: String?
    ) -> String? {
        guard let value else {
            return nil
        }

        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmed.isEmpty ? nil : trimmed
    }

    private func normalizedTags(
        _ tags: [String]?
    ) -> [String]? {
        guard let tags else {
            return nil
        }

        let normalized = tags
            .map {
                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }
            .filter {
                !$0.isEmpty
            }

        return normalized.isEmpty ? nil : normalized
    }

    // MARK: - Validation

    private func validateRequiredFields() -> Bool {
        if allValues.title?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty != false {

            errorMessage = "Title is required."
            return false
        }

        guard allValues.coordinate != nil else {
            errorMessage = "Coordinates are required."
            return false
        }

        guard allValues.type != nil else {
            errorMessage = "Type is required."
            return false
        }

        guard let countryID = allValues.countryID,
              !countryID.isEmpty else {
            errorMessage = "Country is required."
            return false
        }

        guard allValues.date != nil else {
            errorMessage = "Date is required."
            return false
        }

        switch allValues.type {
        case .city:
            guard let cityName = allValues.cityName,
                  !cityName
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty else {

                errorMessage = "City name is required."
                return false
            }

        case .mountain:
            guard let mountainName = allValues.mountainName,
                  !mountainName
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty else {

                errorMessage = "Mountain name is required."
                return false
            }

        case .point, nil:
            break
        }

        return true
    }

    // MARK: - Helpers

    var hasLocation: Bool {
        locationID != nil
    }

    var hasCoordinate: Bool {
        allValues.coordinate != nil
    }
}
