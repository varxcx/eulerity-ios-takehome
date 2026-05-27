//
//  ToggleView.swift
//  EulerityApp
//
//  Created by Vardhan Chopada on 5/27/26.
//


import SwiftUI

struct ToggleView: View {

    let field: FormField
    let theme: FormTheme
    @ObservedObject var vm: FormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            Toggle(isOn: Binding(
                get: { vm.toggleValues[field.id] ?? false },
                set: { vm.toggleValues[field.id] = $0 }
            )) {
                Text(field.label)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(Color(hex: theme.textColor))
            }
            .tint(.blue)
        }
    }
}