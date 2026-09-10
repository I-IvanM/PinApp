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

        return Double(progress.processedCount)
            / Double(progress.totalCount)
    }

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.primary.opacity(0.08))

                    Capsule()
                        .fill(.primary.opacity(0.25))
                        .frame(
                            width: geometry.size.width * progressValue
                        )
                        .animation(
                            .easeInOut(duration: 0.2),
                            value: progressValue
                        )
                }
                .glassEffect(
                    .regular,
                    in: .capsule
                )
            }
            .frame(height: 10)

            Text("\(progress.createdCount) pins added")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: 18)
        )
        .allowsHitTesting(false)
    }
}
