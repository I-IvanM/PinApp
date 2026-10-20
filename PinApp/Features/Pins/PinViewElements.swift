//
//  PinViewElements.swift
//  PinApp
//
//  Created by I_IvanM on 05.09.2026.
//

import SwiftUI

// MARK: - Title

struct PinTitleField: View {

    @ObservedObject var state: PinState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            requiredLabel("Title")

            TextField(
                "Title",
                text: Binding(
                    get: {
                        state.allValues.title ?? ""
                    },
                    set: { newValue in
                        state.allValues.title = newValue
                        state.titleWasAutoFilled = false
                    }
                )
            )
            .textFieldStyle(.plain)
            .pinGlassField()
        }
    }
}

// MARK: - Coordinates

struct PinCoordinatesView: View {

    @ObservedObject var state: PinState

    @FocusState private var focusedField: CoordinateField?

    private enum CoordinateField {
        case latitude
        case longitude
    }

    var body: some View {
        HStack(spacing: 10) {
            coordinateField(
                title: "Latitude",
                text: $state.latitudeText,
                field: .latitude
            )

            coordinateField(
                title: "Longitude",
                text: $state.longitudeText,
                field: .longitude
            )
        }
        .onChange(of: focusedField) { _, newValue in
            if newValue == nil {
                state.updateCoordinateFromTextFields()
            }
        }
    }

    private func coordinateField(
        title: String,
        text: Binding<String>,
        field: CoordinateField
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(
                title,
                text: text
            )
            .textFieldStyle(.plain)
            .keyboardType(.decimalPad)
            .focused(
                $focusedField,
                equals: field
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassEffect(
            .regular,
            in: RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }
}

// MARK: - Country

struct CountryLabel: View {

    @ObservedObject var state: PinState

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "globe")

            Text(state.allValues.countryName ?? "Country")
                .lineLimit(1)
        }
        .foregroundStyle(
            state.allValues.countryName == nil
                ? .secondary
                : .primary
        )
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassEffect(
            .regular,
            in: RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
        .contentShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
        .onLongPressGesture {
            state.countrySearchText =
                state.allValues.countryName ?? ""

            state.isCountryListVisible = true
        }
        .sheet(
            isPresented: $state.isCountryListVisible
        ) {
            PinCountryPicker(state: state)
                .presentationDetents(
                    [.medium, .large]
                )
        }
    }
}

// MARK: - Country Picker

private struct PinCountryPicker: View {

    @ObservedObject var state: PinState

    @Environment(\.dismiss)
    private var dismiss

    private var filteredCountries: [Country] {
        let normalizedSearch = state.countrySearchText
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .folding(
                options: [
                    .caseInsensitive,
                    .diacriticInsensitive
                ],
                locale: .current
            )

        return state.countries.filter { country in
            normalizedSearch.isEmpty ||
            country.countryName
                .folding(
                    options: [
                        .caseInsensitive,
                        .diacriticInsensitive
                    ],
                    locale: .current
                )
                .localizedCaseInsensitiveContains(
                    normalizedSearch
                )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(
                        filteredCountries,
                        id: \.countryID
                    ) { country in
                        Button {
                            state.selectCountry(country)
                            dismiss()
                        } label: {
                            HStack {
                                Text(country.countryName)

                                Spacer()

                                if country.countryID ==
                                    state.allValues.countryID {

                                    Image(
                                        systemName: "checkmark"
                                    )
                                    .foregroundStyle(
                                        .secondary
                                    )
                                }
                            }
                            .foregroundStyle(.primary)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(
                                RoundedRectangle(
                                    cornerRadius: 14,
                                    style: .continuous
                                )
                            )
                        }
                        .buttonStyle(.plain)
                        .glassEffect(
                            .regular,
                            in: RoundedRectangle(
                                cornerRadius: 14,
                                style: .continuous
                            )
                        )
                    }
                }
                .padding()
            }
            .background {
                Color("SettingsBackground")
                    .ignoresSafeArea()
            }
            .navigationTitle("Country")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $state.countrySearchText,
                prompt: "Search countries"
            )
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button("Done") {
                        state.isCountryListVisible = false
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: – Color
struct PinColorPicker: View {

    @ObservedObject var state: PinState

    var body: some View {
        ColorPicker(
            "",
            selection: Binding(
                get: {
                    Color(
                        hex: state.allValues.color
                            ?? state.dependencies
                                .settingsService
                                .defaultPinColorHex
                    ) ?? .red
                },
                set: { newColor in
                    state.allValues.color = newColor.toHex()
                }
            )
        )
        .labelsHidden()
        .frame(width: 44, height: 44)
        .glassEffect(
            .regular.interactive(),
            in: RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
        )
    }
}

/*
// MARK: - Type swipe

struct PinTypeFields: View {

    @ObservedObject var state: PinState

    @Namespace private var glassNamespace

    private let types: [LocationTypeSelection] = [
        .point,
        .city,
        .mountain
    ]

    @State private var dragOffset: CGFloat = 0

    var body: some View {

        VStack(alignment: .leading, spacing: 14) {

            typeSelector

            switch state.allValues.type {

            case .city:
                PinCityFields(state: state)

            case .mountain:
                PinMountainFields(state: state)

            case .point, nil:
                EmptyView()
            }
        }
    }

    private var typeSelector: some View {

        GeometryReader { geometry in

            let totalWidth = geometry.size.width
            let spacing: CGFloat = 4
            let horizontalPadding: CGFloat = 4

            let itemWidth =
                (
                    totalWidth
                    - horizontalPadding * 2
                    - spacing * CGFloat(types.count - 1)
                )
                / CGFloat(types.count)

            let step = itemWidth + spacing

            ZStack(alignment: .leading) {

                selectedGlass(
                    itemWidth: itemWidth,
                    step: step
                )
                .padding(.horizontal, horizontalPadding)

                HStack(spacing: spacing) {

                    ForEach(types, id: \.self) { type in
                        typeItem(type)
                            .frame(width: itemWidth)
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .glassEffect(
                .regular,
                in: Capsule()
            )
            .contentShape(Capsule())
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in

                        let minimumOffset =
                            -step * CGFloat(currentIndex)

                        let maximumOffset =
                            step * CGFloat(types.count - 1 - currentIndex)

                        withTransaction(
                            Transaction(animation: nil)
                        ) {
                            dragOffset = min(
                                max(
                                    value.translation.width,
                                    minimumOffset
                                ),
                                maximumOffset
                            )
                        }
                    }
                    .onEnded { value in

                        finishDrag(
                            translation: value.translation.width,
                            step: step
                        )
                    }
            )
        }
        .frame(height: 48)
    }

    @ViewBuilder
    private func typeItem(
        _ type: LocationTypeSelection
    ) -> some View {

        let isSelected = state.allValues.type == type

        Button {
            select(type)
        } label: {

            Text(typeTitle(type))
                .font(.body)
                .fontWeight(
                    isSelected
                        ? .medium
                        : .regular
                )
                .foregroundStyle(
                    isSelected
                        ? .primary
                        : .secondary
                )
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func selectedGlass(
        itemWidth: CGFloat,
        step: CGFloat
    ) -> some View {

        Capsule()
            .glassEffect(
                .regular.interactive(),
                in: Capsule()
            )
            .glassEffectID(
                "selectedType",
                in: glassNamespace
            )
            .frame(width: itemWidth)
            .offset(
                x: CGFloat(currentIndex) * step
                    + dragOffset
            )
    }
    private var currentIndex: Int {

        guard let type = state.allValues.type,
              let index = types.firstIndex(of: type)
        else {
            return 0
        }

        return index
    }

    private func finishDrag(
        translation: CGFloat,
        step: CGFloat
    ) {

        let position =
            CGFloat(currentIndex)
            + translation / step

        let nearestIndex = Int(
            position.rounded()
        )

        let newIndex = min(
            max(nearestIndex, 0),
            types.count - 1
        )

        withAnimation(.smooth) {

            state.allValues.type =
                types[newIndex]

            dragOffset = 0
        }
    }

    private func select(
        _ type: LocationTypeSelection
    ) {

        withAnimation(.smooth) {

            state.allValues.type = type
            dragOffset = 0
        }
    }

    private func typeTitle(
        _ type: LocationTypeSelection
    ) -> String {

        switch type {

        case .point:
            return "Point"

        case .city:
            return "City"

        case .mountain:
            return "Mountain"
        }
    }
}
 */

// MARK: - Type picker

struct PinTypeFields: View {

    @ObservedObject var state: PinState

    private let types: [LocationTypeSelection] = [
        .point,
        .city,
        .mountain
    ]

    var body: some View {

        VStack(alignment: .leading, spacing: 14) {

            typeSelector

            switch state.allValues.type {

            case .city:
                PinCityFields(state: state)

            case .mountain:
                PinMountainFields(state: state)

            case .point, nil:
                EmptyView()
            }
        }
    }

    private var typeSelector: some View {

        Menu {
            ForEach(types, id: \.self) { type in

                Button {
                    select(type)
                } label: {

                    HStack {

                        Text(typeTitle(type))

                        if state.allValues.type == type {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }

        } label: {

            HStack {

                Text(
                    typeTitle(
                        state.allValues.type ?? .point
                    )
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(.primary)
            }
            .font(.body)
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .frame(
                maxWidth: .infinity,
                minHeight: 46,
                alignment: .leading
            )
            .contentShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .glassEffect(
            .regular.interactive(),
            in: RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }

    private func select(
        _ type: LocationTypeSelection
    ) {

        withAnimation(.smooth) {
            state.allValues.type = type
        }
    }

    private func typeTitle(
        _ type: LocationTypeSelection
    ) -> String {

        switch type {

        case .point:
            return "Point"

        case .city:
            return "City"

        case .mountain:
            return "Mountain"
        }
    }
}
 

// MARK: - City

private struct PinCityFields: View {

    @ObservedObject var state: PinState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            requiredLabel("City")

            TextField(
                "City name",
                text: Binding(
                    get: {
                        state.allValues.cityName ?? ""
                    },
                    set: { newValue in
                        state.allValues.cityName = newValue
                        state.cityNameWasAutoFilled = false
                    }
                )
            )
            .textFieldStyle(.plain)
            .pinGlassField()

            TextField(
                "Address",
                text: Binding(
                    get: {
                        state.allValues.address ?? ""
                    },
                    set: { newValue in
                        state.allValues.address = newValue
                        state.addressWasAutoFilled = false
                    }
                )
            )
            .textFieldStyle(.plain)
            .pinGlassField()
        }
    }
}

// MARK: - Mountain

private struct PinMountainFields: View {

    @ObservedObject var state: PinState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            requiredLabel("Mountain")

            TextField(
                "Mountain name",
                text: Binding(
                    get: {
                        state.allValues.mountainName ?? ""
                    },
                    set: { newValue in
                        state.allValues.mountainName = newValue
                        state.mountainNameWasAutoFilled = false
                    }
                )
            )
            .textFieldStyle(.plain)
            .pinGlassField()

            heightField(
                title: "Height",
                text: $state.heightText
            )

            heightField(
                title: "Achieved height",
                text: $state.achievedHeightText
            )
        }
    }

    private func heightField(
        title: String,
        text: Binding<String>
    ) -> some View {
        HStack(spacing: 8) {
            Text(title)

            Spacer()

            TextField(
                "Height",
                text: text
            )
            .textFieldStyle(.plain)
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
            .frame(width: 100)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .glassEffect(
                .regular,
                in: RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
            )

            Text("m")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Note

struct PinNoteField: View {

    @ObservedObject var state: PinState

    var body: some View {

        TextField(
            "Note",
            text: Binding(
                get: {
                    state.allValues.note ?? ""
                },
                set: { newValue in
                    state.allValues.note = newValue
                }
            ),
            axis: .vertical
        )
        .textFieldStyle(.plain)
        .lineLimit(3...10)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassEffect(
            .regular,
            in: RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }
}

// MARK: - Tags

struct PinTagsField: View {
    @ObservedObject var state: PinState
    var body: some View {
        TextField(
            "Tags",
            text: Binding(
                get: {
                    state.allValues.tags?
                        .joined(separator: ", ") ?? ""
                },
                set: { newValue in

                    let tags = newValue
                        .split(separator: ",")
                        .map {
                            $0.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                        }
                        .filter {
                            !$0.isEmpty
                        }

                    state.allValues.tags =
                        tags.isEmpty ? nil : tags
                }
            )
        )
        .textFieldStyle(.plain)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassEffect(
            .regular,
            in: RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }
}

// MARK: - Date

struct PinDateField: View {
    @ObservedObject var state: PinState
    var body: some View {
        DatePicker(
            "",
            selection: Binding(
                get: {
                    state.allValues.date ?? Date()
                },
                set: { newValue in
                    state.allValues.date = newValue
                }
            ),
            displayedComponents: [.date]
        )
        .labelsHidden()
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassEffect(
            .regular,
            in: RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }
}

// MARK: - Visit count

struct PinVisitCount: View {
    @ObservedObject var state: PinState
    var body: some View {
        HStack {
            HStack(spacing: 5) {
                Text("Times visited:")
                    .foregroundStyle(.secondary)

                Text(
                    "\(state.allValues.pinCount ?? 1)"
                )
                .font(.body.monospacedDigit())
                .fontWeight(.bold)
            }

            Spacer()

            HStack(spacing: 8) {
                Button {
                    let currentValue =
                        state.allValues.pinCount ?? 0

                    state.allValues.pinCount =
                        max(1, currentValue - 1)
                } label: {
                    Image(systemName: "minus")
                        .frame(
                            width: 36,
                            height: 36
                        )
                }
                .buttonStyle(.plain)
                .glassEffect(
                    .regular,
                    in: Circle()
                )

                Button {
                    let currentValue =
                        state.allValues.pinCount ?? 0

                    state.allValues.pinCount =
                        currentValue + 1
                } label: {
                    Image(systemName: "plus")
                        .frame(
                            width: 36,
                            height: 36
                        )
                }
                .buttonStyle(.plain)
                .glassEffect(
                    .regular,
                    in: Circle()
                )
            }
        }
    }
}

// MARK: - Shared UI

private func requiredLabel(
    _ title: String
) -> some View {
    HStack(spacing: 3) {
        Text(title)

        Text("*")
            .foregroundStyle(.red)
    }
}

private struct PinGlassFieldModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(
                minHeight: 46
            )
            .glassEffect(
                .regular,
                in: RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
    }
}

private extension View {

    func pinGlassField() -> some View {
        modifier(PinGlassFieldModifier())
    }
}
