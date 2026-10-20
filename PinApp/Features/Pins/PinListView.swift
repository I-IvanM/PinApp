//
//  PinListView.swift
//  PinApp
//
//  Created by I_IvanM on 11.08.2026.
//

import Foundation
import SwiftUI

struct PinListView: View {

    let dependencies: AppDependencies

    @State private var rows: [PinListRow] = []
    @State private var searchText = ""
    @State private var selectedTypes: Set<LocationTypeSelection> = [
        .point,
        .city,
        .mountain
    ]
    @State private var selectedLocation: SelectedLocation?
    @State private var isFilterExpanded = false
    @State private var hasLoaded = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {

            NavigationStack {
                VStack(spacing: 0) {
                    filterView
                    contentView
                }
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(
                        displayMode: .always
                    ),
                    prompt: "Search"
                )
                .task {
                    guard !hasLoaded else { return }

                    hasLoaded = true
                    await loadLocations()
                }
                .onChange(of: dependencies.updateService.pinListUpdate) {
                    Task {
                        await loadLocations()
                    }
                }
                .sheet(item: $selectedLocation) { selectedLocation in
                    PinView(
                        dependencies: dependencies,
                        locationID: selectedLocation.id,
                        coordinate: nil
                    )
                }
        }
    }

    private var filterView: some View {
        DisclosureGroup(
            isExpanded: $isFilterExpanded
        ) {
            VStack(spacing: 8) {
                filterRow(
                    title: "Point",
                    type: .point
                )

                filterRow(
                    title: "City",
                    type: .city
                )

                filterRow(
                    title: "Mountain",
                    type: .mountain
                )
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
        } label: {
            HStack {
                Text("Location Type")

                Spacer()

                Text(filterDescription)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color("SettingsBackground"))
    }

    private func filterRow(
        title: String,
        type: LocationTypeSelection
    ) -> some View {
        Button {
            toggleType(type)
        } label: {
            HStack(spacing: 10) {
                Image(
                    systemName: selectedTypes.contains(type)
                    ? "checkmark.square.fill"
                    : "square"
                )

                Text(title)

                Spacer()
            }
            .foregroundStyle(.primary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var filterDescription: String {
        if selectedTypes.count == 3 {
            return "All"
        }

        if selectedTypes.isEmpty {
            return "None"
        }

        return selectedTypes
            .map { type in
                switch type {
                case .point:
                    return "Point"

                case .city:
                    return "City"

                case .mountain:
                    return "Mountain"
                }
            }
            .sorted()
            .joined(separator: ", ")
    }

    private func toggleType(
        _ type: LocationTypeSelection
    ) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
    }


    @ViewBuilder
    private var contentView: some View {
        if isLoading {
            ProgressView()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

        } else if let errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                Text(errorMessage)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )

        } else if filteredRows.isEmpty {
            ContentUnavailableView {
                Label(
                    "No Pins",
                    systemImage: "mappin.slash"
                )
            } description: {
                if searchText.isEmpty {
                    Text(
                        "No locations match the selected types."
                    )
                } else {
                    Text(
                        "No locations match your search."
                    )
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )

        } else {
            pinList
        }
    }

    private var pinList: some View {
        List {
            ForEach(filteredRows) { row in
                PinListRowView(row: row)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedLocation = SelectedLocation(
                            id: row.id
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(
                            top: 6,
                            leading: 16,
                            bottom: 6,
                            trailing: 16
                        )
                    )
                    .swipeActions(
                        edge: .trailing,
                        allowsFullSwipe: true
                    ) {
                        Button(role: .destructive) {
                            delete(row)
                        } label: {
                            Label(
                                "Delete",
                                systemImage: "trash"
                            )
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color("SettingsBackground"))
        .scrollIndicators(.hidden)
    }

    private var filteredRows: [PinListRow] {
        rows.filter { row in
            matchesType(row) && matchesSearch(row)
        }
    }

    private func matchesType(
        _ row: PinListRow
    ) -> Bool {
        selectedTypes.contains(row.type)
    }

    private func matchesSearch(
        _ row: PinListRow
    ) -> Bool {
        let query = searchText
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !query.isEmpty else {
            return true
        }

        if row.title.localizedCaseInsensitiveContains(query) {
            return true
        }

        if row.note?.localizedCaseInsensitiveContains(query) == true {
            return true
        }

        if row.tags?.contains(where: {
            $0.localizedCaseInsensitiveContains(query)
        }) == true {
            return true
        }

        return false
    }


    @MainActor
    private func loadLocations() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let locations = try dependencies.locationService.fetchAll()

            rows = try makeRows(
                from: locations
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }


    private func delete(
        _ row: PinListRow
    ) {
        do {
            try dependencies.locationService.delete(id: row.id)

            rows.removeAll {
                $0.id == row.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }


    private func makeRows(
        from locations: [Location]
    ) throws -> [PinListRow] {
        var result: [PinListRow] = []

        result.reserveCapacity(
            locations.count
        )

        for location in locations {
            let row = try makeRow(
                from: location
            )

            result.append(row)
        }

        return result
    }

    private func makeRow(
        from location: Location
    ) throws -> PinListRow {
        switch location.type {

        case .point:
            return PinListRow(
                id: location.id,
                title: location.title,
                color: location.color,
                countryID: location.countryID,
                type: .point,
                note: location.note,
                tags: location.tags
            )

        case .city:
            return PinListRow(
                id: location.id,
                title: location.title,
                color: location.color,
                countryID: location.countryID,
                type: .city,
                note: location.note,
                tags: location.tags
            )

        case .mountain:
            return PinListRow(
                id: location.id,
                title: location.title,
                color: location.color,
                countryID: location.countryID,
                type: .mountain,
                note: location.note,
                tags: location.tags
            )
        }
    }
}


private struct PinListRow: Identifiable {

    let id: UUID
    let title: String
    let color: String
    let countryID: String
    let type: LocationTypeSelection
    let note: String?
    let tags: [String]?
}


private struct SelectedLocation: Identifiable {

    let id: UUID
}


private struct PinListRowView: View {

    let row: PinListRow

    private var pinColor: Color {
        Color(hex: row.color) ?? .gray
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(pinColor)
                .frame(
                    width: 30,
                    height: 30
                )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(row.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 5) {
                    Text(row.countryID)

                    Text("•")

                    Text(typeName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .glassEffect(
            .regular,
            in: RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
    }

    private var iconName: String {
        switch row.type {
        case .point:
            return "mappin"

        case .city:
            return "building.2.fill"

        case .mountain:
            return "mountain.2.fill"
        }
    }

    private var typeName: String {
        switch row.type {
        case .point:
            return "Point"

        case .city:
            return "City"

        case .mountain:
            return "Mountain"
        }
    }
}
