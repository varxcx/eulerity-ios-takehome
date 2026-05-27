//
//  CheckboxView.swift
//  EulerityApp
//
//  Created by Vardhan Chopada on 5/27/26.
//


import SwiftUI

struct CheckboxView: View {

    let field: FormField
    let theme: FormTheme
    @ObservedObject var vm: FormViewModel

    @Environment(\.openURL) private var openURL

    var isChecked: Bool {
        vm.toggleValues[field.id] ?? false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            HStack(alignment: .top, spacing: 10) {

                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: theme.borderColor) ?? .gray, lineWidth: 1.5)
                        .frame(width: 22, height: 22)

                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                .onTapGesture {
                    vm.toggleValues[field.id] = !isChecked
                    vm.errors[field.id] = nil
                }

                Text(labelWithLinks)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: theme.textColor))
                    .environment(\.openURL, OpenURLAction { url in
                        openURL(url)
                        return .handled
                    })
            }

            if let error = vm.errors[field.id] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(Color(hex: theme.errorColor))
                    .padding(.leading, 32)
            }
        }
    }

    var labelWithLinks: AttributedString {
        var result = AttributedString(field.label)

        guard let metadata = field.metadata else { return result }

        let linkColor = Color(hex: field.clickableTextColor ?? "#2563EB") ?? .blue

        for (word, urlString) in metadata {
            guard let url = URL(string: urlString),
                  let range = result.range(of: word) else { continue }
            result[range].link = url
            result[range].foregroundColor = UIColor(linkColor)
            result[range].underlineStyle = .single
        }

        return result
    }
}
