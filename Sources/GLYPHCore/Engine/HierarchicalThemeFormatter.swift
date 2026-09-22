import Foundation

public enum ArchitecturalTheme: String, CaseIterable, Identifiable, Sendable {
    case obeliskGothic = "Obelisk Apex"
    case cyberMatrix = "Cyber Conduit"
    case alchemicalSanctum = "Alchemical Sanctum"
    case engulfingVortex = "Engulfing Vortex"
    case celestialVoid = "Celestial Void"
    case royalBaroque = "Royal Baroque"
    case nordicRune = "Nordic Rune"
    case proceduralRandom = "🎲 Procedural Permutation"
    
    public var id: String { rawValue }
}

public struct HierarchicalThemeFormatter: Sendable {
    
    /// Formats a parsed document into a museum-grade layout with strict column limits (<= 24 cols)
    public static func format(
        document: ParsedDocument,
        theme: ArchitecturalTheme = .obeliskGothic,
        fontStyle: TypographyStyle = .frakturBold
    ) -> String {
        switch theme {
        case .obeliskGothic:
            return formatObeliskGothic(document: document, fontStyle: fontStyle)
        case .cyberMatrix:
            return formatCyberMatrix(document: document, fontStyle: fontStyle)
        case .alchemicalSanctum:
            return formatAlchemicalSanctum(document: document, fontStyle: fontStyle)
        case .engulfingVortex:
            return formatEngulfingVortex(document: document, fontStyle: fontStyle)
        case .celestialVoid:
            return formatCelestialVoid(document: document, fontStyle: fontStyle)
        case .royalBaroque:
            return formatRoyalBaroque(document: document, fontStyle: fontStyle)
        case .nordicRune:
            return formatNordicRune(document: document, fontStyle: fontStyle)
        case .proceduralRandom:
            return formatProceduralRandom(document: document, fontStyle: fontStyle)
        }
    }
    
    // MARK: - 1. Obelisk Gothic (Screenshot Matching, max 24 cols)
    
    private static func formatObeliskGothic(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        
        let rawTitle = document.title.isEmpty ? "MASTER CATALOG" : document.title
        let styledTitle = converter.convert(fitText(rawTitle.uppercased(), maxVisualWidth: 11), to: fontStyle)
        
        lines.append("             ▲")
        lines.append("            ╱ ╲")
        lines.append("           ╱ ◈ ╲")
        lines.append("          ╱ ⚔︎ ⚔︎ ╲")
        lines.append("         ╱ ░▒▓▒░ ╲")
        lines.append("        ╱  𖤍 𖤍 𖤍  ╲")
        lines.append("       ╱ ═════════ ╲")
        lines.append("      ╱ \(center(styledTitle, width: 11)) ╲")
        lines.append("     ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀")
        lines.append("      ░▒▓█ 𖤍 █▓▒░")
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("        ▲   ▲")
                lines.append("       ▲ ◈ ▲ ◈ ▲")
                lines.append("      ◄ ❖ ⚔︎ ❖ ►")
                lines.append("       ▼ ◈ ▼ ◈ ▼")
                lines.append("        ▼   ▼")
                lines.append("")
            }
            
            let styledCat = converter.convert(fitText(category.name.uppercased(), maxVisualWidth: 14), to: fontStyle)
            lines.append("░░▒▒▓▓████████████▓▓▒▒░░")
            lines.append("▓  ༺ \(center(styledCat, width: 14)) ༻  ▓")
            lines.append("░░▒▒▓▓████████████▓▓▒▒░░")
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(fitText(dept.name.uppercased(), maxVisualWidth: 18), to: fontStyle)
                
                lines.append("       𓆩 ⚡︎ 𓆪")
                lines.append("╭━━━━━━━━━━━━━━━━━━━━╮")
                lines.append("┃ \(center(styledDept, width: 18)) ┃")
                lines.append("╰━━━━━━━━━━━━━━━━━━━━╯")
                
                for (itemIndex, item) in dept.items.enumerated() {
                    lines.append("◈ \(fitText(item.name.uppercased(), maxVisualWidth: 22))")
                    
                    for option in item.options {
                        if !option.detail.isEmpty {
                            lines.append("  ┠ \(fitText(option.detail, maxVisualWidth: 20))")
                        }
                        if !option.price.isEmpty {
                            lines.append("  ┃ ➔ \(fitText(option.price, maxVisualWidth: 17))")
                        }
                    }
                    
                    if itemIndex < dept.items.count - 1 {
                        lines.append("  ╍╍╍╍╍ ❖ ╍╍╍╍╍")
                    }
                }
                lines.append("")
            }
        }
        
        if !document.operationalNotes.isEmpty {
            lines.append("  ╍╍╍╍╍ ❖ ╍╍╍╍╍")
            for note in document.operationalNotes {
                lines.append("┠ \(fitText(note, maxVisualWidth: 21))")
            }
            lines.append("")
        }
        
        lines.append("      ░▒▓█ 𖤍 █▓▒░")
        lines.append("    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀")
        lines.append("     ╲ \(center(styledTitle, width: 11)) ╱")
        lines.append("      ╲ ═════════ ╱")
        lines.append("       ╲  𖤍 𖤍 𖤍  ╱")
        lines.append("        ╲ ░▒▓▒░ ╱")
        lines.append("         ╲ ⚔︎ ⚔︎ ╱")
        lines.append("          ╲ ◈ ╱")
        lines.append("           ╲ ╱")
        lines.append("            ▼")
        
        return lines.joined(separator: "\n")
    }
    
    // MARK: - 2. Cyber Matrix (Strict <= 24 cols)
    
    private static func formatCyberMatrix(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        let style = (fontStyle == .frakturBold) ? .monospace : fontStyle
        
        let rawTitle = document.title.isEmpty ? "CYBER MATRIX" : document.title
        let styledTitle = converter.convert(fitText(rawTitle.uppercased(), maxVisualWidth: 12), to: style)
        
        lines.append("┌───[ ⬡ ⌬ ⬡ ]───┐")
        lines.append("│ ░▒ \(center(styledTitle, width: 12)) ▒░ │")
        lines.append("└───[ ⬡ ⌬ ⬡ ]───┘")
        lines.append("  ⚡︎ ─ ─ ─ ─ ─ ─ ⚡︎")
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("  ⬡ ═ ═ ⌬ ═ ═ ⬡")
                lines.append("")
            }
            
            let styledCat = converter.convert(fitText(category.name.uppercased(), maxVisualWidth: 10), to: style)
            lines.append("═━═[ ⏣ \(center(styledCat, width: 10)) ⏣ ]═━═")
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(fitText(dept.name.uppercased(), maxVisualWidth: 12), to: style)
                lines.append("╔═[ ⚡︎ \(center(styledDept, width: 12)) ]═╗")
                
                for (itemIndex, item) in dept.items.enumerated() {
                    lines.append("⌬ \(fitText(item.name.uppercased(), maxVisualWidth: 22))")
                    for option in item.options {
                        if !option.detail.isEmpty {
                            lines.append("  ╟── \(fitText(option.detail, maxVisualWidth: 18))")
                        }
                        if !option.price.isEmpty {
                            lines.append("  ╚═▶ [ \(fitText(option.price, maxVisualWidth: 14)) ]")
                        }
                    }
                    if itemIndex < dept.items.count - 1 {
                        lines.append("  ─ ─ ─ ─ ⌬ ─ ─ ─ ─")
                    }
                }
                lines.append("╚══════════════════════╝")
                lines.append("")
            }
        }
        
        lines.append("  ⚡︎ ─ ─ ─ ─ ─ ─ ⚡︎")
        lines.append("└─[ ⬡ TERMINATION ⬡ ]─┘")
        return lines.joined(separator: "\n")
    }
    
    // MARK: - 3. Alchemical Sanctum (Strict <= 24 cols)
    
    private static func formatAlchemicalSanctum(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        
        let rawTitle = document.title.isEmpty ? "HERMETIC VAULT" : document.title
        let styledTitle = converter.convert(fitText(rawTitle.uppercased(), maxVisualWidth: 12), to: fontStyle)
        
        lines.append("        ☉ ☽ ☿")
        lines.append("╔══════════════════════╗")
        lines.append("║   ༺ \(center(styledTitle, width: 12)) ༻   ║")
        lines.append("╚══════════════════════╝")
        lines.append("        ᚛ ༒ ᚜")
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("      ᚛ ☉ ☽ ☿ ᚜")
                lines.append("")
            }
            
            let styledCat = converter.convert(fitText(category.name.uppercased(), maxVisualWidth: 12), to: fontStyle)
            lines.append("░▒▓ ༒ \(center(styledCat, width: 12)) ༒ ▓▒░")
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(fitText(dept.name.uppercased(), maxVisualWidth: 14), to: fontStyle)
                lines.append("        𓆩 𖤍 𓆪")
                lines.append("╭───── ❖ ─────╮")
                lines.append("│ \(center(styledDept, width: 14)) │")
                lines.append("╰───── ❖ ─────╯")
                
                for (itemIndex, item) in dept.items.enumerated() {
                    lines.append("✦ \(fitText(item.name.uppercased(), maxVisualWidth: 22))")
                    for option in item.options {
                        if !option.detail.isEmpty {
                            lines.append("  ├─ \(fitText(option.detail, maxVisualWidth: 19))")
                        }
                        if !option.price.isEmpty {
                            lines.append("  └─► \(fitText(option.price, maxVisualWidth: 17))")
                        }
                    }
                    if itemIndex < dept.items.count - 1 {
                        lines.append("  ───── ༓ ─────")
                    }
                }
                lines.append("")
            }
        }
        
        lines.append("        ᚛ ༒ ᚜")
        lines.append("╚══════════════════════╝")
        lines.append("        ☉ ☽ ☿")
        return lines.joined(separator: "\n")
    }
    
    // MARK: - 4. Engulfing Vortex (Strict <= 24 cols)
    
    private static func formatEngulfingVortex(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        
        let rawTitle = document.title.isEmpty ? "VORTEX CONDUIT" : document.title
        let styledTitle = converter.convert(fitText(rawTitle.uppercased(), maxVisualWidth: 12), to: fontStyle)
        
        lines.append("░▒▓██████████████████▓▒░")
        lines.append("▓▒  ༺ \(center(styledTitle, width: 12)) ༻  ▒▓")
        lines.append("░▒▓██████████████████▓▒░")
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("▓▒░  ▲ ◈ ❖ ◈ ▲  ░▒▓")
                lines.append("")
            }
            
            let styledCat = converter.convert(fitText(category.name.uppercased(), maxVisualWidth: 10), to: fontStyle)
            lines.append("▓▒░ ◈ \(center(styledCat, width: 10)) ◈ ░▒▓")
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(fitText(dept.name.uppercased(), maxVisualWidth: 10), to: fontStyle)
                lines.append("▓▒ ╭━━ \(center(styledDept, width: 10)) ━━╮ ▒▓")
                
                for (itemIndex, item) in dept.items.enumerated() {
                    lines.append("▓▒ ◈ \(fitText(item.name.uppercased(), maxVisualWidth: 15)) ▒▓")
                    for option in item.options {
                        if !option.detail.isEmpty {
                            lines.append("▓▒   ┠ \(fitText(option.detail, maxVisualWidth: 13)) ▒▓")
                        }
                        if !option.price.isEmpty {
                            lines.append("▓▒   ┃ ➔ \(fitText(option.price, maxVisualWidth: 11)) ▒▓")
                        }
                    }
                    if itemIndex < dept.items.count - 1 {
                        lines.append("▓▒   ╍╍ ❖ ╍╍   ▒▓")
                    }
                }
                lines.append("▓▒ ╰━━━━━━━━━━━━━━━╯ ▒▓")
                lines.append("")
            }
        }
        
        lines.append("░▒▓██████████████████▓▒░")
        return lines.joined(separator: "\n")
    }
    
    // MARK: - 5. Celestial Void (Strict <= 24 cols)
    
    private static func formatCelestialVoid(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        let style = (fontStyle == .frakturBold) ? .cursiveBold : fontStyle
        
        let rawTitle = document.title.isEmpty ? "CELESTIAL REALM" : document.title
        let styledTitle = converter.convert(fitText(rawTitle.uppercased(), maxVisualWidth: 10), to: style)
        
        lines.append("        ★ ✵ ✧ ✦")
        lines.append("         ☾ ⋆ ☽")
        lines.append("╭─── ✦ \(center(styledTitle, width: 10)) ✦ ───╮")
        lines.append("╰──────────────────────╯")
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("       ★ ⋆ ✦ ⋆ ★")
                lines.append("")
            }
            
            let styledCat = converter.convert(fitText(category.name.uppercased(), maxVisualWidth: 10), to: style)
            lines.append("★ ━━━━━━━━━━━━━━━━━━━━ ★")
            lines.append("    ༺ \(center(styledCat, width: 10)) ༻")
            lines.append("★ ━━━━━━━━━━━━━━━━━━━━ ★")
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(fitText(dept.name.uppercased(), maxVisualWidth: 10), to: style)
                lines.append("        𓆩 𖤍 𓆪")
                lines.append("╭── ☾ \(center(styledDept, width: 10)) ☽ ──╮")
                
                for (itemIndex, item) in dept.items.enumerated() {
                    lines.append("✧ \(fitText(item.name.uppercased(), maxVisualWidth: 22))")
                    for option in item.options {
                        if !option.detail.isEmpty {
                            lines.append("  ┠ \(fitText(option.detail, maxVisualWidth: 20))")
                        }
                        if !option.price.isEmpty {
                            lines.append("  ┃ ➔ \(fitText(option.price, maxVisualWidth: 17))")
                        }
                    }
                    if itemIndex < dept.items.count - 1 {
                        lines.append("  · · · ✵ · · ·")
                    }
                }
                lines.append("╰──────────────────────╯")
                lines.append("")
            }
        }
        
        lines.append("         ☾ ⋆ ☽")
        lines.append("        ★ ✵ ✧ ✦")
        return lines.joined(separator: "\n")
    }
    
    // MARK: - 6. Royal Baroque (Strict <= 24 cols)
    
    private static func formatRoyalBaroque(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        
        let rawTitle = document.title.isEmpty ? "ROYAL VAULT" : document.title
        let styledTitle = converter.convert(fitText(rawTitle.uppercased(), maxVisualWidth: 12), to: fontStyle)
        
        lines.append("       ꧁ ༺ ♔ ༻ ꧂")
        lines.append("  ╔══════════════════╗")
        lines.append("  ║   \(center(styledTitle, width: 12))   ║")
        lines.append("  ╚══════════════════╝")
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("       ❧ ━ ❦ ━ ❧")
                lines.append("")
            }
            
            let styledCat = converter.convert(fitText(category.name.uppercased(), maxVisualWidth: 12), to: fontStyle)
            lines.append("❧ ━━━━━━━━━━━━━━━━━━━━ ❦")
            lines.append("     ꧁ \(center(styledCat, width: 12)) ꧂")
            lines.append("❧ ━━━━━━━━━━━━━━━━━━━━ ❦")
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(fitText(dept.name.uppercased(), maxVisualWidth: 14), to: fontStyle)
                lines.append("        𓆩 ♕ 𓆪")
                lines.append("╭━━━ \(center(styledDept, width: 14)) ━━━╮")
                
                for (itemIndex, item) in dept.items.enumerated() {
                    lines.append("❖ \(fitText(item.name.uppercased(), maxVisualWidth: 22))")
                    for option in item.options {
                        if !option.detail.isEmpty {
                            lines.append("  ├─ \(fitText(option.detail, maxVisualWidth: 19))")
                        }
                        if !option.price.isEmpty {
                            lines.append("  └─ \(fitText(option.price, maxVisualWidth: 17))")
                        }
                    }
                    if itemIndex < dept.items.count - 1 {
                        lines.append("  ~ ~ ~ ❦ ~ ~ ~")
                    }
                }
                lines.append("╰━━━━━━━━━━━━━━━━━━━━━━╯")
                lines.append("")
            }
        }
        
        lines.append("  ╔══════════════════╗")
        lines.append("       ꧁ ༺ ♔ ༻ ꧂")
        return lines.joined(separator: "\n")
    }
    
    // MARK: - 7. Nordic Rune (Strict <= 24 cols)
    
    private static func formatNordicRune(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        
        let rawTitle = document.title.isEmpty ? "VALHALLA VAULT" : document.title
        let styledTitle = converter.convert(fitText(rawTitle.uppercased(), maxVisualWidth: 12), to: fontStyle)
        
        lines.append("      ᚛ ᚠ ᚢ ᚦ ᚨ ᚱ ᚜")
        lines.append(" █▓▒░ \(center(styledTitle, width: 12)) ░▒▓█")
        lines.append("      ᚛ ᚠ ᚢ ᚦ ᚨ ᚱ ᚜")
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("      ᚛═══ ❖ ═══᚜")
                lines.append("")
            }
            
            let styledCat = converter.convert(fitText(category.name.uppercased(), maxVisualWidth: 10), to: fontStyle)
            lines.append("▓▒░ ᚛ \(center(styledCat, width: 10)) ᚜ ░▒▓")
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(fitText(dept.name.uppercased(), maxVisualWidth: 12), to: fontStyle)
                lines.append("        ⚔︎ ᚦ ⚔︎")
                lines.append("┌───── ᚛ ᚜ ─────┐")
                lines.append("│ \(center(styledDept, width: 12)) │")
                lines.append("└───── ᚛ ᚜ ─────┘")
                
                for (itemIndex, item) in dept.items.enumerated() {
                    lines.append("᚛ \(fitText(item.name.uppercased(), maxVisualWidth: 22))")
                    for option in item.options {
                        if !option.detail.isEmpty {
                            lines.append("  ┠ \(fitText(option.detail, maxVisualWidth: 20))")
                        }
                        if !option.price.isEmpty {
                            lines.append("  ┃ ➔ \(fitText(option.price, maxVisualWidth: 17))")
                        }
                    }
                    if itemIndex < dept.items.count - 1 {
                        lines.append("  ╍╍╍ ᛟ ╍╍╍")
                    }
                }
                lines.append("")
            }
        }
        
        lines.append("      ᚛ ᚠ ᚢ ᚦ ᚨ ᚱ ᚜")
        return lines.joined(separator: "\n")
    }
    
    // MARK: - 8. Procedural Permutation
    
    private static func formatProceduralRandom(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        let allThemes: [ArchitecturalTheme] = [
            .obeliskGothic, .cyberMatrix, .alchemicalSanctum,
            .engulfingVortex, .celestialVoid, .royalBaroque, .nordicRune
        ]
        let picked = allThemes.randomElement() ?? .obeliskGothic
        return format(document: document, theme: picked, fontStyle: fontStyle)
    }
    
    // MARK: - Helpers
    
    public static func center(_ text: String, width: Int) -> String {
        let visualLen = TextWidthMetrics.visualColumnWidth(of: text)
        if visualLen >= width { return text }
        let totalPad = width - visualLen
        let leftPad = totalPad / 2
        let rightPad = totalPad - leftPad
        return String(repeating: " ", count: leftPad) + text + String(repeating: " ", count: rightPad)
    }
    
    public static func fitText(_ text: String, maxVisualWidth: Int) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if TextWidthMetrics.visualColumnWidth(of: trimmed) <= maxVisualWidth {
            return trimmed
        }
        var result = ""
        for char in trimmed {
            if TextWidthMetrics.visualColumnWidth(of: result + String(char)) > maxVisualWidth - 1 {
                return result + "…"
            }
            result.append(char)
        }
        return result
    }
}
