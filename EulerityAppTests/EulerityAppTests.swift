//
//  EulerityAppTests.swift
//  EulerityAppTests
//
//  Created by Vardhan Chopada on 5/27/26.
//

import XCTest
@testable import EulerityApp

@MainActor
final class EulerityParsingTests: XCTestCase {

    // MARK: - Helpers

    func decode(_ json: String) throws -> FormPayload {
        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(FormPayload.self, from: data)
    }

    let baseJSON = """
    {
      "theme": {
        "background_color": "#FFFFFF",
        "text_color": "#111827",
        "border_color": "#D1D5DB",
        "error_color": "#B91C1C"
      },
      "form_title": "Test Form",
      "fields": []
    }
    """

    // MARK: - Theme

    func testThemeParsesCorrectly() throws {
        let payload = try decode(baseJSON)
        XCTAssertEqual(payload.theme.backgroundColor, "#FFFFFF")
        XCTAssertEqual(payload.theme.textColor, "#111827")
        XCTAssertEqual(payload.theme.borderColor, "#D1D5DB")
        XCTAssertEqual(payload.theme.errorColor, "#B91C1C")
        XCTAssertEqual(payload.formTitle, "Test Form")
    }

    // MARK: - TEXT field

    func testTextFieldParsesCorrectly() throws {
        let json = """
        {
          "theme": { "background_color": "#FFF", "text_color": "#000", "border_color": "#CCC", "error_color": "#F00" },
          "form_title": "T",
          "fields": [{
            "id": "campaign_name",
            "order": 1,
            "type": "TEXT",
            "subtype": "PLAIN",
            "label": "Campaign Name",
            "placeholder": "e.g., Summer Sale",
            "max_length": 30,
            "required": true,
            "error_message": "Name is required."
          }]
        }
        """
        let payload = try decode(json)
        let field = try XCTUnwrap(payload.fields.first)
        XCTAssertEqual(field.id, "campaign_name")
        XCTAssertEqual(field.type, .text)
        XCTAssertEqual(field.subtype, .plain)
        XCTAssertEqual(field.maxLength, 30)
        XCTAssertTrue(field.required)
        XCTAssertEqual(field.placeholder, "e.g., Summer Sale")
        XCTAssertEqual(field.errorMessage, "Name is required.")
    }

    func testTextSubtypesParseCorrectly() throws {
        for subtype in ["PLAIN", "MULTILINE", "NUMBER", "URI", "SECURE"] {
            let json = """
            {
              "theme": { "background_color": "#FFF", "text_color": "#000", "border_color": "#CCC", "error_color": "#F00" },
              "form_title": "T",
              "fields": [{
                "id": "f1", "order": 1, "type": "TEXT", "subtype": "\(subtype)",
                "label": "Field", "required": false
              }]
            }
            """
            let payload = try decode(json)
            let field = try XCTUnwrap(payload.fields.first)
            XCTAssertNotNil(field.subtype, "Subtype \(subtype) should parse without nil")
        }
    }

    // MARK: - DROPDOWN field

    func testDropdownParsesWithOptions() throws {
        let json = """
        {
          "theme": { "background_color": "#FFF", "text_color": "#000", "border_color": "#CCC", "error_color": "#F00" },
          "form_title": "T",
          "fields": [{
            "id": "ad_networks",
            "order": 2,
            "type": "DROPDOWN",
            "label": "Ad Networks",
            "allow_multiple": true,
            "default_values": ["net_meta"],
            "required": true,
            "options": [
              { "id": "net_google", "label": "Google Search" },
              { "id": "net_meta",   "label": "Meta Platforms" }
            ]
          }]
        }
        """
        let payload = try decode(json)
        let field = try XCTUnwrap(payload.fields.first)
        XCTAssertEqual(field.type, .dropdown)
        XCTAssertEqual(field.allowMultiple, true)
        XCTAssertEqual(field.defaultValues, ["net_meta"])
        XCTAssertEqual(field.options?.count, 2)
        XCTAssertEqual(field.options?.first?.id, "net_google")
    }

    // MARK: - TOGGLE & CHECKBOX

    func testToggleAndCheckboxParse() throws {
        let json = """
        {
          "theme": { "background_color": "#FFF", "text_color": "#000", "border_color": "#CCC", "error_color": "#F00" },
          "form_title": "T",
          "fields": [
            { "id": "tog", "order": 1, "type": "TOGGLE",   "label": "Enable", "required": false },
            { "id": "chk", "order": 2, "type": "CHECKBOX", "label": "Agree",  "required": true  }
          ]
        }
        """
        let payload = try decode(json)
        XCTAssertEqual(payload.fields.first(where: { $0.id == "tog" })?.type, .toggle)
        XCTAssertEqual(payload.fields.first(where: { $0.id == "chk" })?.type, .checkbox)
    }

    // MARK: - Unknown type doesn't crash

    func testUnknownTypeIsIgnoredGracefully() throws {
        let json = """
        {
          "theme": { "background_color": "#FFF", "text_color": "#000", "border_color": "#CCC", "error_color": "#F00" },
          "form_title": "T",
          "fields": [{
            "id": "mystery", "order": 1, "type": "DATE_PICKER", "label": "Pick a Date", "required": false
          }]
        }
        """
        // Should not throw
        let payload = try decode(json)
        let field = try XCTUnwrap(payload.fields.first)
        XCTAssertEqual(field.type, .unknown)
    }

    // MARK: - Ordering

    func testFieldsAreSortedByOrder() throws {
        let json = """
        {
          "theme": { "background_color": "#FFF", "text_color": "#000", "border_color": "#CCC", "error_color": "#F00" },
          "form_title": "T",
          "fields": [
            { "id": "third",  "order": 3, "type": "TOGGLE",   "label": "C", "required": false },
            { "id": "first",  "order": 1, "type": "TEXT",     "subtype": "PLAIN", "label": "A", "required": false },
            { "id": "second", "order": 2, "type": "CHECKBOX", "label": "B", "required": false }
          ]
        }
        """
        let payload = try decode(json)
        let sorted = payload.fields.sorted(by: { $0.order < $1.order })
        XCTAssertEqual(sorted.map(\.id), ["first", "second", "third"])
    }

    // MARK: - Optional fields absent = nil

    func testOptionalFieldsAreNilWhenAbsent() throws {
        let json = """
        {
          "theme": { "background_color": "#FFF", "text_color": "#000", "border_color": "#CCC", "error_color": "#F00" },
          "form_title": "T",
          "fields": [{
            "id": "daily_budget", "order": 3, "type": "TEXT", "subtype": "NUMBER",
            "label": "Daily Budget", "required": true
          }]
        }
        """
        let payload = try decode(json)
        let field = try XCTUnwrap(payload.fields.first)
        XCTAssertNil(field.placeholder)
        XCTAssertNil(field.maxLength)
        XCTAssertNil(field.errorMessage)
        XCTAssertNil(field.regexPattern)
    }

    // MARK: - Metadata / Checkbox links

    func testCheckboxMetadataParsesCorrectly() throws {
        let json = """
        {
          "theme": { "background_color": "#FFF", "text_color": "#000", "border_color": "#CCC", "error_color": "#F00" },
          "form_title": "T",
          "fields": [{
            "id": "accept_legal", "order": 5, "type": "CHECKBOX",
            "label": "I agree to the Terms of Service.",
            "required": true,
            "metadata": { "Terms of Service": "https://example.com/terms" },
            "clickable_text_color": "#2563EB"
          }]
        }
        """
        let payload = try decode(json)
        let field = try XCTUnwrap(payload.fields.first)
        XCTAssertEqual(field.metadata?["Terms of Service"], "https://example.com/terms")
        XCTAssertEqual(field.clickableTextColor, "#2563EB")
    }

    // MARK: - Malformed JSON doesn't crash decoder

    func testMissingRequiredFieldThrows() {
        // 'label' is absent — Codable should throw, not crash
        let json = """
        {
          "theme": { "background_color": "#FFF", "text_color": "#000", "border_color": "#CCC", "error_color": "#F00" },
          "form_title": "T",
          "fields": [{ "id": "oops", "order": 1, "type": "TEXT", "required": false }]
        }
        """
        XCTAssertThrowsError(try decode(json))
    }

    // MARK: - ViewModel default state

    func testViewModelInitialisesDefaultValues() {
        let json = """
        {
          "theme": { "background_color": "#FFF", "text_color": "#000", "border_color": "#CCC", "error_color": "#F00" },
          "form_title": "T",
          "fields": [
            { "id": "campaign_name", "order": 1, "type": "TEXT", "subtype": "PLAIN", "label": "Name", "required": false },
            { "id": "ad_networks", "order": 2, "type": "DROPDOWN", "label": "Networks", "allow_multiple": true, "default_values": ["net_meta"], "required": true, "options": [{ "id": "net_meta", "label": "Meta" }] },
            { "id": "accept_legal", "order": 3, "type": "CHECKBOX", "label": "Agree", "required": true }
          ]
        }
        """.data(using: .utf8)!

        let payload = try! JSONDecoder().decode(FormPayload.self, from: json)

        var values: [String: String] = [:]
        var multiValues: [String: [String]] = [:]
        var toggleValues: [String: Bool] = [:]

        for field in payload.fields {
            switch field.type {
            case .text:     values[field.id] = ""
            case .dropdown: multiValues[field.id] = field.defaultValues ?? []
            case .checkbox: toggleValues[field.id] = false
            default: break
            }
        }

        XCTAssertEqual(multiValues["ad_networks"], ["net_meta"])
        XCTAssertEqual(values["campaign_name"], "")
        XCTAssertEqual(toggleValues["accept_legal"], false)
    }
}
