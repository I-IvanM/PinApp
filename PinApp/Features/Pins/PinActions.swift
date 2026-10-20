//
//  PinActions.swift
//  PinApp
//
//  Created by I_IvanM on 05.09.2026.
//

import Foundation
import SwiftUI

struct PinActions: View {

    @ObservedObject var state: PinState

    let isEditing: Bool

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {

        HStack(spacing: 12) {

            if isEditing {

                Button(role: .destructive) {
                    delete()
                } label: {

                    Text("Delete Pin")
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
                .glassEffect(
                    .regular,
                    in: RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
            }

            Button {
                save()
            } label: {

                Text("Save")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
            .glassEffect(
                .regular,
                in: RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    // MARK: - Actions

    private func save() {

        Task {

            do {
                try await state.save()
                dismiss()
            } catch {
                state.errorMessage =
                    error.localizedDescription
            }
        }
    }

    private func delete() {

        state.delete()

        guard state.errorMessage == nil else {
            return
        }

        dismiss()
    }
}
