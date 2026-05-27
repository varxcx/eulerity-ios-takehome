//
//  ColorEXT.swift
//  EulerityApp
//
//  Created by Vardhan Chopada on 5/27/26.
//

import SwiftUI

// MARK: - Color Helper
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        guard hex.count == 6, let value = UInt64(hex, radix: 16) else { return nil }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
