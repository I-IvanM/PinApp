//
//  PinView.swift
//  PinApp
//
//  Created by I_IvanM on 11.08.2026.
//

import SwiftUI

struct PinView: View {

    let dependencies: AppDependencies
    let locationID: UUID?
    let coordinate: Coordinate?

    @Environment(\.dismiss)
    private var dismiss

    @StateObject
    private var state: PinState

    init(
        dependencies: AppDependencies,
        locationID: UUID? = nil,
        coordinate: Coordinate? = nil
    ) {
        self.dependencies = dependencies
        self.locationID = locationID
        self.coordinate = coordinate

        _state = StateObject(
            wrappedValue: PinState(
                dependencies: dependencies,
                locationID: locationID,
                coordinate: coordinate
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    PinTitleField(state: state)
                    // PinCoordinatesView(state: state) // It is possible to enter the coordinate yourself here, but I don't think anyone needs that.
                    HStack{
                        CountryLabel(state: state)
                        PinColorPicker(state: state)
                        Spacer()
                    }
                    PinDateField(state: state)
                    PinTypeFields(state: state)
                    PinNoteField(state: state)
                    PinTagsField(state: state)
                    PinVisitCount(state: state)
                    PinActions(
                        state: state,
                        isEditing: locationID != nil
                    )
                }
                .padding()
            }
            .background {
                Color("SettingsBackground")
                    .ignoresSafeArea()
            }
            .navigationTitle(coordinateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .task {
                await state.prepare()
            }
            .onChange(of: state.allValues.type) {
                state.synchronizeTypeSpecificTextFields()
            }
            .overlay {
                if state.isLoading {
                    ProgressView()
                }
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: {
                        state.errorMessage != nil
                    },
                    set: { newValue in
                        if !newValue {
                            state.errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK") {
                    state.errorMessage = nil
                }
            } message: {
                Text(
                    state.errorMessage ?? ""
                )
            }
        }
    }
    
    private var coordinateTitle: String {
        guard let coordinate = state.allValues.coordinate else {
            return "Pin"
        }

        return "\(coordinate.latitude), \(coordinate.longitude)"
    }
}
