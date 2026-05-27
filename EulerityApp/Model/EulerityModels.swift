//
//  EulerityModels.swift
//  EulerityApp
//
//  Created by Vardhan Chopada on 5/26/26.
//

import Foundation

// MARK: - Theme

struct FormTheme: Decodable {
    let backgroundColor: String
    let textColor: String
    let borderColor: String
    let errorColor: String

    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case borderColor = "border_color"
        case errorColor = "error_color"
    }
}

// MARK: - Form

struct FormPayload: Decodable {
    let theme: FormTheme
    let formTitle: String
    let fields: [FormField]

    enum CodingKeys: String, CodingKey {
        case theme
        case formTitle = "form_title"
        case fields
    }
}

// MARK: - Field

struct FormField: Decodable, Identifiable {
    let id: String
    let order: Int
    let type: FieldType
    let label: String
    let required: Bool

    let subtype: TextSubtype?
    let placeholder: String?
    let maxLength: Int?
    let errorMessage: String?
    let regexPattern: String?  
    let options: [DropdownOption]?
    let allowMultiple: Bool?
    let defaultValues: [String]?
    let metadata: [String: String]?
    let clickableTextColor: String?

    enum CodingKeys: String, CodingKey {
        case id, order, type, label, required, subtype, placeholder, options, metadata
        case maxLength = "max_length"
        case errorMessage = "error_message"
        case regexPattern = "regex_pattern"
        case allowMultiple = "allow_multiple"
        case defaultValues = "default_values"
        case clickableTextColor = "clickable_text_color"
    }
}

// MARK: - Enums

enum FieldType: String, Decodable {
    case text = "TEXT"
    case dropdown = "DROPDOWN"
    case toggle = "TOGGLE"
    case checkbox = "CHECKBOX"
    case unknown

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = FieldType(rawValue: raw) ?? .unknown
    }
}

enum TextSubtype: String, Decodable {
    case plain = "PLAIN"
    case multiline = "MULTILINE"
    case number = "NUMBER"
    case uri = "URI"
    case secure = "SECURE"
}

// MARK: - Dropdown Option

struct DropdownOption: Decodable, Identifiable {
    let id: String
    let label: String
}


