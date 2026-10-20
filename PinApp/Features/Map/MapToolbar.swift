//
//  MapToolbar.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import SwiftUI

struct MapToolbar: View {

    let onShowUserLocation: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()

                Button {
                    onShowUserLocation()
                } label: {
                    Image(systemName: "location.fill")
                        .font(.title3.weight(.semibold))
                        .frame(width: 44, height: 44)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                }
                .padding()
            }

            Spacer()
        }
    }
}
