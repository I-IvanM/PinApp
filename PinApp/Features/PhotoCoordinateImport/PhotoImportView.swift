//
//  PhotoImportView.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import SwiftUI

struct PhotoImportView: View {

    let dependencies: AppDependencies

    @State private var isShowingConfirmation = false
    @State private var isImporting = false
    
    @State private var progress = PhotoImportProgress(
        processedCount: 0,
        totalCount: 0,
        createdCount: 0
    )

    var body: some View {
        ZStack(alignment: .top) {
            settingsContent

            if isImporting {
                progressView
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .transition(
                        .move(edge: .top)
                        .combined(with: .opacity)
                    )
                    .zIndex(1)
            }
        }
        .sheet(isPresented: $isShowingConfirmation) {
            confirmationView
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
        }
    }

    private var settingsContent: some View {
        Button {
            guard !isImporting else {
                return
            }

            isShowingConfirmation = true
        } label: {
            Label(
                "Import from Photos",
                systemImage: "photo.on.rectangle"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glass)
        .tint(.primary)
        .padding(.horizontal)
    }

    private var confirmationView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Import from Photos")
                    .font(.headline)

                Text(
                    "Photos are processed only on this device. "
                    + "Nothing is uploaded. Keep the app open during import."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            Button {
                isShowingConfirmation = false
                startImport()
            } label: {
                Text("Start Import")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
        }
        .padding()
    }

    private var progressView: some View {
        PhotoImportProgressView(
            progress: progress
        )
    }

    private func startImport() {
        guard !isImporting else {
            return
        }

        isImporting = true
        progress = PhotoImportProgress(
            processedCount: 0,
            totalCount: 0,
            createdCount: 0
        )

        Task {
            do {
                try await dependencies
                    .fromPhotoCoordinatesImportService
                    .importPhotos { progress in

                        self.progress = progress
                    }
            } catch {
                print("Photo import failed: \(error)")
            }

            isImporting = false
        }
    }
}
