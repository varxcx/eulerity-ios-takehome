//
//  TextInputView.swift
//  EulerityApp
//
//  Created by Vardhan Chopada on 5/27/26.
//
import SwiftUI

struct TextInputView: View {

    let field: FormField
    let theme: FormTheme
    @ObservedObject var vm: FormViewModel

    let focusedField: FocusState<String?>.Binding
    let nextFieldId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(field.label)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color(hex: theme.textColor))

            switch field.subtype {

            case .secure:
                SecureField(field.placeholder ?? "", text: binding)
                    .focused(focusedField, equals: field.id)
                    .submitLabel(nextFieldId == nil ? .done : .next)
                    .onSubmit { moveFocus() }
                    .inputStyle(theme: theme, hasError: hasError)

            case .multiline:
                TextField(field.placeholder ?? "", text: binding, axis: .vertical)
                    .lineLimit(3...6)
                    .focused(focusedField, equals: field.id)
                    .inputStyle(theme: theme, hasError: hasError)

            case .number:
                TextField(field.placeholder ?? "", text: binding)
                    .keyboardType(.decimalPad)
                    .focused(focusedField, equals: field.id)
                    .inputStyle(theme: theme, hasError: hasError)

            case .uri:
                TextField(field.placeholder ?? "", text: binding)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused(focusedField, equals: field.id)
                    .submitLabel(nextFieldId == nil ? .done : .next)
                    .onSubmit { moveFocus() }
                    .inputStyle(theme: theme, hasError: hasError)

            default:
                TextField(field.placeholder ?? "", text: binding)
                    .focused(focusedField, equals: field.id)
                    .submitLabel(nextFieldId == nil ? .done : .next)
                    .onSubmit { moveFocus() }
                    .inputStyle(theme: theme, hasError: hasError)
            }

            if let max = field.maxLength {
                let count = vm.values[field.id]?.count ?? 0
                HStack {
                    Spacer()
                    Text("\(count)/\(max)")
                        .font(.caption)
                        .foregroundColor(count >= max ? Color(hex: theme.errorColor) : .gray)
                }
            }


            if field.subtype == .number, let raw = vm.values[field.id], let daily = Double(raw), daily > 0 {
                HStack(spacing: 12) {
                    Label("~$\(Int(daily * 7).formatted()) / week", systemImage: "calendar")
                    Divider().frame(height: 12)
                    Label("~$\(Int(daily * 30.4).formatted()) / month", systemImage: "chart.line.uptrend.xyaxis")
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 2)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.25), value: vm.values[field.id])
            }
            
            if let error = vm.errors[field.id] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(Color(hex: theme.errorColor))
            }
        }
    }
    
    func moveFocus() {
        focusedField.wrappedValue = nextFieldId
    }

    var binding: Binding<String> {
        Binding(
            get: { vm.values[field.id] ?? "" },
            set: { newValue in
                var filtered = newValue
                if field.subtype == .number {
                    filtered = newValue.filter { $0.isNumber || $0 == "." }
                }
                if let max = field.maxLength, filtered.count > max {
                    filtered = String(filtered.prefix(max))
                }
                vm.values[field.id] = filtered
                vm.errors[field.id] = nil
            }
        )
    }

    var hasError: Bool {
        vm.errors[field.id] != nil
    }
}

// MARK: - Shared input styling
extension View {
    func inputStyle(theme: FormTheme, hasError: Bool) -> some View {
        self
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
}
