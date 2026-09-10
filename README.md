# PinApp

PinApp is a free open-source iOS app for saving visited places and showing travel statistics. It uses pins on a map and fills visited countries with color. One of the main features is importing locations from photo coordinates from Iphoto. The import filters photos so that many photos from the same place don't create a lot of pins in the same place, so they don't overlap.

Similar apps are available in the App Store, but many have Significant limits and paid subscriptions. PinApp sllows to create an unlimited number of pins and can turn all photos from the photo library into pins at once.

The app is structured for gradual development, so services are built around the main models, using which new location types and features can be added easily.

## Contents

- [Usage](#usage)
  - [Features](#features)
  - [Install and run with Xcode](#install-and-run-with-xcode)
  - [Data sources](#data-sources)
- [Development](#development)
  - [Project structure](#project-structure)
  - [Main models](#main-models)
  - [Photo coordinate import](#photo-coordinate-import)
  - [Adding a location type](#adding-a-location-type)

## Usage

### Features

- Show saved locations as pins on a map.
- Filling countries with color after a pin is added.
- Create, edit, search, filter, and delete pins.
- Use the `Point`, `City`, and `Mountain` location types.
- View statistics for countries, continents, and location types.
- Import photo coordinates from the device photo library.
- Choose a default pin color, a map fill color, and a map style.

The app has four tabs:

- **Map** shows pins, visited countries, and the current user location. Long press on the map to create a pin.
- **Pins** shows all saved pins as a list. Search and filters help find a location by title, country, tag, or type.
- **Statistics** shows travel progress by countries and continents, as well as totals for each location type.
- **Settings** map appearance settings and photo coordinate import button.

### Install and run with Xcode

Requirements:

- A Mac that can run a current version of Xcode with iOS 26.5 support (or later).
- An iPhone running iOS 26.5 or later, or an iPad or an iOS Simulator.
- An Apple ID to run the app on a personal iPhone.

1. Download and install Xcode from the Mac App Store.
2. Download or clone this repository.
3. Open PinApp.xcodeproj in Xcode.
4. In the Xcode toolbar, choose an iPhone Simulator or connect an iPhone by cable and select it as the run destination.
5. If Xcode asks for signing information or something similar, it is normal and it means that you need to set some usual settings, that apple requires. [Here](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices) you can find all neaded information.
Briefly, open the PinApp target, select "Signing & Capabilities", choose your Apple development team, and let Xcode create a unique bundle identifier if needed. 
6. Press the Run button.
7. If you are running the app on a physical device you may need to turn on the developer mode and confirm that you trust this developer in the iPhone settings. [Instruction](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)
8. When the app asks for permissions, allow location access to show your current position and allow photo library access before importing photos.

### Data sources

- Country polygons in `Countries.geojson` are based on [Natural Earth GeoJSON country boundaries](https://github.com/martynafford/natural-earth-geojson/blob/master/10m/cultural/ne_10m_admin_0_countries.json).
- Country names, ISO codes, and regional data in `Countries.json` are based on [ISO 3166 Countries with Regional Codes](https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.json).
- The country list was processed with ChatGPT by [OpenAI](https://openai.com/) to match the format used by PinApp.

## Development

### Project structure

```text
PinApp/
├── App/             App entry point and dependency setup
├── Features/        SwiftUI screens for map, pins, statistics, settings, and import
├── Core/
│   ├── Domain/      Models, value objects, and enums
│   ├── Services/    App logic around the domain models
│   ├── Storage/     Database setup and repository protocols
│   └── Infrastructure/ SwiftData, MapKit, Photos, geometry, and Core Location
├── Resources/       GeoJSON, country seed data, assets, and localised strings
└── Shared/          Reusable UI components and extensions
```

`AppDependencies` creates repositories and services, then passes them to the views. `SwiftData` stores user data locally. `MapKit` renders pins and country polygons. `UpdateService` notifies the map, pin list, and statistics screens after data changes.

### Main models

`Location` is the central model. Every pin has a uuid, title, coordinate, country identifier, LocationType, date, color, visit count, note(optional), tags (optional), and photo identifiers (they are not used anywhere at the moment, I just dont want to change db in the future:).

Additional main models extend `Location` when a type needs shared information. At present, these are `City` and `Mountain`:

- `City` stores a city name, its centre coordinate, and the number of pins connected to it. `CityVisitData` stores visit-specific data such as the address.
- `Mountain` stores a mountain name, height, coordinate, and number of pins connected to it. `MountainVisitData` stores visit-specific data such as achieved height.
- `Country` stores the country name, ISO identifier (for example 'DE' for Germany), continent, and number of pins in the country.
- `Photo` is not used now, I created it to not change the db in the future.
– `PhotoMetadata` supports photo library import.

For a complete guide to extending this model system, see [Adding a location type](#adding-a-location-type).

### Photo coordinate import

Processing of photographic data runs only on the device, so it is never being uploaded.

The app asks for full photo library access and reads every photo metadata. A photo can create a pin only when it has geographic metadata. The import then applies the following checks in order:

1. Photos without coordinates are skipped.
2. A photo is skipped when it was made too close in time to the previously accepted photo. The current interval is at least `60 seconds`.
3. A photo is skipped when its coordinate is too close to any existing pin, including a pin created earlier in the same import. The current minimal distance is abount 5 km.
4. Every accepted photo creates a `Point` (neither a city nor a mountain) through `CreationService`, so country counting, storage, and UI updates use the same flow as a manually created pin.

To compare coordinates, the app calculates their angular distance on a sphere. The two positions on the Earth surface are represented as vectors from the Earth centre. Their vector projections and the cosine theorem give the angle $θ$ between the vectors:

$$
cos(θ) = cos(φ₁) × cos(φ₂) × cos(λ₁ − λ₂) + sin(φ₁) × sin(φ₂)
θ = arccos(cos(θ))
$$

Here, $φ$ is latitude and $λ$ is longitude. The programm uses the minimum angle $0.0007848$ radians. Which corresponds to 5 km: average Earth radius $R = 6371$ km, the angle: $ θ = 5 / R = 0.0007848$ radians.

Although earth is not a perfect sphere (Its radius is roughly 6357–6378 km), using one average radius creates only a small distance error that depends on the place on Earth. At a 5 km threshold, the error is at most about 11 metres. This is acceptable because the calculation is used only to prevent pins from overlapping, not to measure an exact distance.

### Adding a location type

This guide uses the existing `Mountain` type as the example. To add a new type, repeat the same pattern with your own names and fields. For example, replace Mountain with lake.

#### 1. Define the domain data

Create the shared model in Core/Domain/Models/. In our case Mountain.swift. It contains data that may be shared by several pins, such as mountainName, height, mountainCoordinate, and mountainPinCount.

Create the visit-specific payload in Core/Domain/Models/. In our case MountainVisitData.swift. This data belongs to one Location, for example achievedHeight. The payload must conform to Codable, because it is stored as encoded type data.

Add the new cases to both enums:

- Core/Domain/Enums/LocationType.swift needs a case with the visit payload, such as `case mountain(MountainVisitData)`.
- Core/Domain/Enums/LocationTypeSelection.swift needs the matching simple case, such as `case mountain`.

Add fields required by the editor to Core/Domain/Models/AllValues.swift. The mountain fields are mountainName, height, mountainCoordinate, mountainPinCount, and achievedHeight.

#### 2. Add local storage

Create a SwiftData model in Core/Infrastructure/SwiftData/SwiftDataModels/ю In our case SwiftDataMountain.swift.

Then create all parts of the repository layer:

- Core/Storage/Repository protocols/MountainRepository.swift defines fetch, save, and delete operations.
- Core/Infrastructure/SwiftData/Repositories/SwiftDataMountainRepository.swift implements those operations and converts between Mountain and SwiftDataMountain.
- Core/Services/MountainService.swift provides model-specific logic, including plusPin(for:) and minusPin(for:).

Register the SwiftData model in Core/Storage/Database/Database.swift, inside ModelContainer. Register the repository and service in App/AppDependencies.swift, then pass the service to every service that needs it.

Finally, update Core/Infrastructure/SwiftData/Repositories/SwiftDataLocationRepository.swift. Add the new case in makeSwiftDataLocation(from:) so the type is stored as the correct LocationTypeSelection. The encoded LocationType payload in typeData will then preserve the visit-specific fields.

#### 3. Create, update, and delete the type correctly

In Core/Services/CreationService.swift:

1. Add the new service as a dependency and property.
2. Add a new branch to `create(from:)`.
3. Create a dedicated function following `createMountain(from:newLocation:oldLocation:isNew:countryID:)`.
4. In that function, find or create the shared model, increase its pin count for a new pin, save it, and assign the related `LocationType` payload to `newLocation.type`.
5. Update `removeOldObject(from:)` so a pin that changes from this type to another type decreases the old shared model count.

In Core/Services/LocationService.swift:

- Add the type to `saveLocation(_:)` and round its identity coordinate consistently.
- Add it to `delete(id:)` and call the matching `minusPin(for:)` method.
- Add the new service to the init and AppDependencies call site.

These steps keep shared-object counts correct during creation, editing, type changes, and deletion.

#### 4. Add the editor UI

Update Features/Pins/PinState.swift:

- Add initial `AllValues` fields in init.
- Add state needed for type-specific text fields and automatic filling, if required.
- Add a case to `loadLocation(_:)`.
- Create a loader following `loadMountain(at:)` to fetch the shared model.
- Update `synchronizeTypeSpecificTextFields()`, automatic filling, and validation where the new fields need special handling.

In Features/Pins/PinViewElements.swift:

- Add the type to the `types` array used by `PinTypeFields`.
- Add a case to the type selector switch.
- Create a form view following `PinMountainFields` for the new fields.
- Add a readable type title in the helper switch used by the selector.

`Features/Pins/PinView.swift` already observes `state.allValues.type`, so it will refresh the type-specific fields after these changes.

#### 5. Show the type in lists and statistics

Update Features/Pins/PinListView.swift:

- Add the type to the initial `selectedTypes` set.
- Add a filter row and update the all-types count in `filterDescription`.
- Add the type to the mapping that creates `PinListRow` values.
- Add an icon and a readable name in `PinListRowView`.

Update the statistics flow:

- Add a count property to `Core/Domain/Models/StatisticsValues.swift`.
- Set it to `0` in `Core/Services/StatisticsService.calculate()`.
- Increase it in `calculateLocationStatistics(locations:statistics:)`.
- Add an icon and key path to `Features/Statistics/StatisticsLocationTypes.swift`.

#### 6. Check everything

Check all of the following before considering the feature complete:

1. Create the type manually and confirm that it appears on the map and in the pin list.
2. Edit its fields and confirm that the shared object and visit-specific data remain correct.
3. Change a pin from the new type to `Point` or another type, then check that the old shared-object count decreases.
4. Delete the pin and check that the shared object is removed when its count reaches zero.
5. Use the Pins filter and confirm that the new type has the correct name and icon.
6. Open Statistics and confirm that its total changes.
7. Restart the app and confirm that the type and all its fields are still present.
