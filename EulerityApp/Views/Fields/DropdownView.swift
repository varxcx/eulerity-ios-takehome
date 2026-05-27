//
//  DropdownView.swift
//  EulerityApp
//
//  Created by Vardhan Chopada on 5/27/26.
//


import SwiftUI

struct DropdownView: View {

    let field: FormField
    let theme: FormTheme
    @ObservedObject var vm: FormViewModel

    var selected: [String] {
        vm.multiValues[field.id] ?? []
    }

    var displayText: String {
        let labels = (field.options ?? [])
            .filter { selected.contains($0.id) }
            .map { $0.label }
        return labels.isEmpty ? "Select..." : labels.joined(separator: ", ")
    }

    var hasError: Bool {
        vm.errors[field.id] != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(field.label)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color(hex: theme.textColor))

            Menu {
                ForEach(field.options ?? []) { option in
                    Button {
                        toggle(option.id)
                    } label: {
                        HStack {
                            Text(option.label)
                            if selected.contains(option.id) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(displayText)
                        .foregroundColor(selected.isEmpty ? .gray : Color(hex: theme.textColor))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            hasError
                                ? (Color(hex: theme.errorColor) ?? .red)
                                : (Color(hex: theme.borderColor) ?? .gray),
                            lineWidth: 1
                        )
                )
            }

            if let error = vm.errors[field.id] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(Color(hex: theme.errorColor))
            }
        }
    }

    func toggle(_ id: String) {
        var current = vm.multiValues[field.id] ?? []
        let allowMultiple = field.allowMultiple ?? false

        if allowMultiple {
            if current.contains(id) {
                current.removeAll { $0 == id }
            } else {
                current.append(id)
            }
        } else {
            current = [id]
        }

        vm.multiValues[field.id] = current
        vm.errors[field.id] = nil
    }
}
