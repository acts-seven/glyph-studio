import Foundation

public enum TypographyStyle: String, CaseIterable, Identifiable, Sendable {
    case frakturBold = "Gothic Bold"
    case fraktur = "Gothic"
    case cursiveBold = "Script Bold"
    case cursive = "Script"
    case doubleStruck = "Blackboard"
    case sansBold = "Sans Bold"
    case sansItalic = "Sans Italic"
    case monospace = "Typewriter"
    case smallCaps = "Small Caps"
    case circled = "Circled"
    case squared = "Squared"

    public var id: String { rawValue }
}

public final class UnicodeFontConverter: Sendable {
    public static let shared = UnicodeFontConverter()
    private init() {}

    /// Irregular mappings in Mathematical Alphanumeric block (Unicode 1.0 conflicts in Letterlike Symbols)
    private let letterlikeExceptions: [TypographyStyle: [Character: UInt32]] = [
        .doubleStruck: [
            "C": 0x2102, "H": 0x210D, "N": 0x2115, "P": 0x2119,
            "Q": 0x211A, "R": 0x211D, "Z": 0x2124
        ],
        .fraktur: [
            "C": 0x212D, "H": 0x210C, "I": 0x2111, "R": 0x211C, "Z": 0x2128
        ],
        .cursive: [
            "B": 0x212C, "E": 0x2130, "F": 0x2131, "H": 0x210B,
            "I": 0x2110, "L": 0x2112, "M": 0x2133, "R": 0x211B,
            "e": 0x212F, "g": 0x210A, "o": 0x2134
        ]
    ]

    private let smallCapsMap: [Character: String] = [
        "a": "ᴀ", "b": "ʙ", "c": "ᴄ", "d": "ᴅ", "e": "ᴇ", "f": "ꜰ", "g": "ɢ",
        "h": "ʜ", "i": "ɪ", "j": "ᴊ", "k": "ᴋ", "l": "ʟ", "m": "ᴍ", "n": "ɴ",
        "o": "ᴏ", "p": "ᴘ", "q": "ǫ", "r": "ʀ", "s": "ꜱ", "t": "ᴛ", "u": "ᴜ",
        "v": "ᴠ", "w": "ᴡ", "x": "x", "y": "ʏ", "z": "ᴢ",
        "A": "ᴀ", "B": "ʙ", "C": "ᴄ", "D": "ᴅ", "E": "ᴇ", "F": "ꜰ", "G": "ɢ",
        "H": "ʜ", "I": "ɪ", "J": "ᴊ", "K": "ᴋ", "L": "ʟ", "M": "ᴍ", "N": "ɴ",
        "O": "ᴏ", "P": "ᴘ", "Q": "ǫ", "R": "ʀ", "S": "ꜱ", "T": "ᴛ", "U": "ᴜ",
        "V": "ᴠ", "W": "ᴡ", "X": "x", "Y": "ʏ", "Z": "ᴢ"
    ]

    public func convert(_ text: String, to style: TypographyStyle) -> String {
        if style == .smallCaps {
            return text.map { smallCapsMap[$0] ?? String($0) }.joined()
        }

        var output = ""
        output.reserveCapacity(text.count * 2)

        for char in text {
            if let exceptions = letterlikeExceptions[style],
               let overrideCode = exceptions[char],
               let scalar = UnicodeScalar(overrideCode) {
                output.append(Character(scalar))
                continue
            }

            guard let ascii = char.asciiValue else {
                output.append(char)
                continue
            }

            if let transformedScalar = transformASCII(ascii, for: style) {
                output.append(Character(transformedScalar))
            } else {
                output.append(char)
            }
        }
        return output
    }

    private func transformASCII(_ ascii: UInt8, for style: TypographyStyle) -> UnicodeScalar? {
        // Uppercase: 65 - 90
        if ascii >= 65 && ascii <= 90 {
            let offset = UInt32(ascii - 65)
            switch style {
            case .frakturBold: return UnicodeScalar(0x1D538 + offset)
            case .fraktur:     return UnicodeScalar(0x1D504 + offset)
            case .cursiveBold: return UnicodeScalar(0x1D4D0 + offset)
            case .cursive:     return UnicodeScalar(0x1D49C + offset)
            case .doubleStruck:return UnicodeScalar(0x1D538 + offset)
            case .sansBold:    return UnicodeScalar(0x1D5D4 + offset)
            case .sansItalic:  return UnicodeScalar(0x1D608 + offset)
            case .monospace:   return UnicodeScalar(0x1D670 + offset)
            case .circled:     return UnicodeScalar(0x24B6 + offset)
            case .squared:     return UnicodeScalar(0x1F170 + offset)
            case .smallCaps:   return nil
            }
        }
        // Lowercase: 97 - 122
        if ascii >= 97 && ascii <= 122 {
            let offset = UInt32(ascii - 97)
            switch style {
            case .frakturBold: return UnicodeScalar(0x1D552 + offset)
            case .fraktur:     return UnicodeScalar(0x1D51E + offset)
            case .cursiveBold: return UnicodeScalar(0x1D4EA + offset)
            case .cursive:     return UnicodeScalar(0x1D4B6 + offset)
            case .doubleStruck:return UnicodeScalar(0x1D552 + offset)
            case .sansBold:    return UnicodeScalar(0x1D5EE + offset)
            case .sansItalic:  return UnicodeScalar(0x1D622 + offset)
            case .monospace:   return UnicodeScalar(0x1D68A + offset)
            case .circled:     return UnicodeScalar(0x24D0 + offset)
            case .squared:     return UnicodeScalar(0x1F170 + offset)
            case .smallCaps:   return nil
            }
        }
        // Digits: 48 - 57
        if ascii >= 48 && ascii <= 57 {
            let offset = UInt32(ascii - 48)
            switch style {
            case .doubleStruck: return UnicodeScalar(0x1D7D8 + offset)
            case .sansBold:     return UnicodeScalar(0x1D7EC + offset)
            case .monospace:    return UnicodeScalar(0x1D7F6 + offset)
            case .circled:      return UnicodeScalar(0x2460 + offset)
            default:            return UnicodeScalar(UInt32(ascii))
            }
        }
        return UnicodeScalar(UInt32(ascii))
    }
}
