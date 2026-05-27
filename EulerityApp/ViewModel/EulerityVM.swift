//
//  EulerityVM.swift
//  EulerityApp
//
//  Created by Vardhan Chopada on 5/26/26.
//

import SwiftUI
import Combine

class FormViewModel: ObservableObject {

    @Published var payload: FormPayload?
    @Published var values: [String: String] = [:]
    @Published var multiValues: [String: [String]] = [:]
    @Published var toggleValues: [String: Bool] = [:]
    @Published var errors: [String: String] = [:]
    @Published var showSuccess = false

    init() {
        loadForm()
    }

    // MARK: - Load JSON

    func loadForm() {
        guard let url = Bundle.main.url(forResource: "form", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let parsed = try? JSONDecoder().decode(FormPayload.self, from: data)
        else { return }

        self.payload = parsed

        for field in parsed.fields {
            switch field.type {
            case .text:     values[field.id] = ""
            case .dropdown: multiValues[field.id] = field.defaultValues ?? []
            case .toggle:   toggleValues[field.id] = false
            case .checkbox: toggleValues[field.id] = false
            case .unknown:  break
            }
        }
    }

    // MARK: - Validate & Submit

    func submit() {
        guard let fields = payload?.fields else { return }

        errors = [:]
        var isValid = true

        for field in fields {
            // Check required fields are not empty
            if field.required {
                let isEmpty: Bool
                switch field.type {
                case .text:     isEmpty = (values[field.id] ?? "").trimmingCharacters(in: .whitespaces).isEmpty
                case .dropdown: isEmpty = (multiValues[field.id] ?? []).isEmpty
                case .checkbox: isEmpty = !(toggleValues[field.id] ?? false)
                case .toggle, .unknown: isEmpty = false
                }

                if isEmpty {
                    errors[field.id] = field.errorMessage ?? "This field is required."
                    isValid = false
                    continue
                }
            }

            if field.type == .text,
               let pattern = field.regexPattern,
               let value = values[field.id],
               !value.isEmpty {
                if !value.matches(pattern: pattern) {
                    errors[field.id] = field.errorMessage ?? "Invalid format."
                    isValid = false
                }
            }
        }

        if isValid {
            printResults(fields: fields)
            showSuccess = true
        }
    }
    
    var firstErrorFieldId: String? {
        guard let fields = payload?.fields.sorted(by: { $0.order < $1.order }) else { return nil }
        return fields.first { errors[$0.id] != nil }?.id
    }

    // MARK: - Print to Console

    private func printResults(fields: [FormField]) {
        print("\n=== Form Submitted ===")
        for field in fields.sorted(by: { $0.order < $1.order }) {
            switch field.type {
            case .text:             print("\(field.id): \(values[field.id] ?? "")")
            case .dropdown:         print("\(field.id): \(multiValues[field.id] ?? [])")
            case .toggle, .checkbox: print("\(field.id): \(toggleValues[field.id] ?? false)")
            case .unknown:          break
            }
        }
        print("=====================\n")
    }
}

private extension String {
    func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return true }
        let range = NSRange(startIndex..., in: self)
        return regex.firstMatch(in: self, range: range) != nil
    }
}
