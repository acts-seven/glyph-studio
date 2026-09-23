import Foundation

public struct LineSafetyReport: Identifiable, Sendable {
    public let id: Int
    public let content: String
    public let visualColumns: Int
    public let status: SafetyStatus

    public enum SafetyStatus: Sendable {
        case safe      // 0 - 24 chars
        case warning   // 25 - 28 chars
        case danger    // 29+ chars
    }
}

public struct TextWidthMetrics {
    /// Computes the exact visual column width (wcwidth) of a string for mobile chat bubble layout
    public static func visualColumnWidth(of string: String) -> Int {
        var width = 0
        for char in string {
            if char.unicodeScalars.contains(where: { $0.value == 0xFE0E }) {
                width += 1
            } else if char.unicodeScalars.contains(where: { $0.value == 0xFE0F || $0.properties.isEmojiPresentation }) {
                width += 2
            } else if let scalar = char.unicodeScalars.first, isEastAsianWide(scalar) {
                width += 2
            } else if char.unicodeScalars.allSatisfy({ $0.properties.generalCategory == .nonspacingMark || $0.value == 0x200D }) {
                width += 0
            } else {
                width += 1
            }
        }
        return width
    }

    private static func isEastAsianWide(_ scalar: Unicode.Scalar) -> Bool {
        let v = scalar.value
        return (v >= 0x1100 && v <= 0x115F)
            || (v >= 0x2E80 && v <= 0xA4CF)
            || (v >= 0xAC00 && v <= 0xD7A3)
            || (v >= 0xF900 && v <= 0xFAFF)
            || (v >= 0xFE10 && v <= 0xFE19)
            || (v >= 0xFE30 && v <= 0xFE6F)
            || (v >= 0xFF00 && v <= 0xFF60)
            || (v >= 0xFFE0 && v <= 0xFFE6)
    }
}

public struct WrapToleranceSensor {
    public static func inspect(text: String) -> [LineSafetyReport] {
        let lines = text.components(separatedBy: .newlines)
        return lines.enumerated().map { index, line in
            let columns = TextWidthMetrics.visualColumnWidth(of: line)
            let status: LineSafetyReport.SafetyStatus
            if columns <= 24 {
                status = .safe
            } else if columns <= 28 {
                status = .warning
            } else {
                status = .danger
            }
            return LineSafetyReport(id: index + 1, content: line, visualColumns: columns, status: status)
        }
    }
}
