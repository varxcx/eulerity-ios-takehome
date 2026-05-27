//
//  SuccessView.swift
//  EulerityApp
//
//  Created by Vardhan Chopada on 5/27/26.
//

import SwiftUI

struct SuccessView: View {

    let payload: FormPayload
    let values: [String: String]
    let multiValues: [String: [String]]
    let toggleValues: [String: Bool]
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 32)

                    VStack(spacing: 6) {
                        Text("Campaign Ready!")
                            .font(.title2.weight(.bold))
                        Text("Here's a summary of what you submitted.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 1) {
                        ForEach(payload.fields.sorted { $0.order < $1.order }) { field in
                            if let display = displayValue(for: field) {
                                HStack(alignment: .top, spacing: 12) {
                                    Text(field.label)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .frame(width: 130, alignment: .leading)
                                    Text(display)
                                        .font(.subheadline.weight(.medium))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(.secondarySystemBackground))
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    Button {
                        isPresented = false
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Submitted")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func displayValue(for field: FormField) -> String? {
        switch field.type {
        case .text:
            let val = values[field.id]?.trimmingCharacters(in: .whitespaces) ?? ""
            return val.isEmpty ? nil : val
        case .dropdown:
            let selected = multiValues[field.id] ?? []
            guard !selected.isEmpty else { return nil }
            let labels = (field.options ?? [])
                .filter { selected.contains($0.id) }
                .map { $0.label }
            return labels.joined(separator: ", ")
        case .toggle:
            return (toggleValues[field.id] ?? false) ? "On" : "Off"
        case .checkbox:
            return (toggleValues[field.id] ?? false) ? "✓ Agreed" : nil
        case .unknown:
            return nil
        }
    }
}
