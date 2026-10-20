//
//  PhotoImportProgressView.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import SwiftUI

struct PhotoImportProgressView: View {

    let progress: PhotoImportProgress

    private var progressValue: Double {
        guard progress.totalCount > 0 else {
            return 0
        }

        return min(
            1,
            max(
                0,
                Double(progress.processedCount) / Double(progress.totalCount)
            )
        )
    }

    var body: some View {
        VStack(spacing: 8) {
            progressBar

            Text("\(progress.createdCount) pins added")
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: 18)
        )
        .allowsHitTesting(false)
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.primary.opacity(0.08))

                Capsule()
                    .fill(.primary.opacity(0.18))
                    .frame(
                        width: geometry.size.width * progressValue
                    )
                    .animation(
                        .easeInOut(duration: 0.2),
                        value: progressValue
                    )
            }
            .overlay {
                Capsule()
                    .stroke(
                        .primary.opacity(0.12),
                        lineWidth: 0.5
                    )
            }
        }
        .frame(height: 12)
        .glassEffect(
            .regular,
            in: .capsule
        )
    }
}
