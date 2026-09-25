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
    
    /// Formats a parsed document into a museum-grade layout with strict column limits (<= 24 cols),
    /// intelligently wrapping all text lines across word boundaries so zero information is lost.
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
    
    // MARK: - 1. Obelisk Gothic (Strict <= 24 cols with Smart Wrapping)
    
    private static func formatObeliskGothic(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        
        let rawTitle = document.title.isEmpty ? "MASTER CATALOG" : document.title
        let styledTitle = converter.convert(rawTitle.uppercased(), to: fontStyle)
        let wrappedTitles = wrapText(styledTitle, maxVisualWidth: 11)
        
        lines.append("             ▲")
        lines.append("            ╱ ╲")
        lines.append("           ╱ ◈ ╲")
        lines.append("          ╱ ⚔︎ ⚔︎ ╲")
        lines.append("         ╱ ░▒▓▒░ ╲")
        lines.append("        ╱  𖤍 𖤍 𖤍  ╲")
        lines.append("       ╱ ═════════ ╲")
        for tLine in wrappedTitles {
            lines.append("      ╱ \(center(tLine, width: 11)) ╲")
        }
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
            
            let styledCat = converter.convert(category.name.uppercased(), to: fontStyle)
            let wrappedCats = wrapText(styledCat, maxVisualWidth: 14)
            lines.append("░░▒▒▓▓████████████▓▓▒▒░░")
            for cLine in wrappedCats {
                lines.append("▓  ༺ \(center(cLine, width: 14)) ༻  ▓")
            }
            lines.append("░░▒▒▓▓████████████▓▓▒▒░░")
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(dept.name.uppercased(), to: fontStyle)
                
                lines.append("       𓆩 ⚡︎ 𓆪")
                appendWrappedBox(
                    lines: &lines,
                    text: styledDept,
                    topBorder: "╭━━━━━━━━━━━━━━━━━━━━╮",
                    bottomBorder: "╰━━━━━━━━━━━━━━━━━━━━╯",
                    leftGutter: "┃ ",
                    rightGutter: " ┃",
                    contentWidth: 18,
                    centerLines: true
                )
                
                for (itemIndex, item) in dept.items.enumerated() {
                    appendWrappedItem(
                        lines: &lines,
                        text: item.name.uppercased(),
                        bullet: "◈ ",
                        continuationIndent: "  ",
                        maxVisualWidth: 24
                    )
                    
                    for option in item.options {
                        if !option.detail.isEmpty {
                            appendWrappedItem(
                                lines: &lines,
                                text: option.detail,
                                bullet: "  ┠ ",
                                continuationIndent: "  ┃ ",
                                maxVisualWidth: 24
                            )
                        }
                        if !option.price.isEmpty {
                            appendWrappedItem(
                                lines: &lines,
                                text: option.price,
                                bullet: "  ┃ ➔ ",
                                continuationIndent: "  ┃   ",
                                maxVisualWidth: 24
                            )
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
                appendWrappedItem(
                    lines: &lines,
                    text: note,
                    bullet: "┠ ",
                    continuationIndent: "┃ ",
                    maxVisualWidth: 24
                )
            }
            lines.append("")
        }
        
        lines.append("      ░▒▓█ 𖤍 █▓▒░")
        lines.append("    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀")
        for tLine in wrappedTitles {
            lines.append("     ╲ \(center(tLine, width: 11)) ╱")
        }
        lines.append("      ╲ ═════════ ╱")
        lines.append("       ╲  𖤍 𖤍 𖤍  ╱")
        lines.append("        ╲ ░▒▓▒░ ╱")
        lines.append("         ╲ ⚔︎ ⚔︎ ╱")
        lines.append("          ╲ ◈ ╱")
        lines.append("           ╲ ╱")
        lines.append("            ▼")
        
        return lines.joined(separator: "\n")
    }
    
    // MARK: - 2. Cyber Matrix (Strict <= 24 cols with Smart Wrapping)
    
    private static func formatCyberMatrix(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        let style = (fontStyle == .frakturBold) ? .monospace : fontStyle
        
        let rawTitle = document.title.isEmpty ? "CYBER MATRIX" : document.title
        let styledTitle = converter.convert(rawTitle.uppercased(), to: style)
        
        appendWrappedBox(
            lines: &lines,
            text: styledTitle,
            topBorder: "┌───[ ⬡ ⌬ ⬡ ]───┐",
            bottomBorder: "└───[ ⬡ ⌬ ⬡ ]───┘",
            leftGutter: "│ ░▒ ",
            rightGutter: " ▒░ │",
            contentWidth: 10,
            centerLines: true
        )
        lines.append("  ⚡︎ ─ ─ ─ ─ ─ ─ ⚡︎")
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("  ⬡ ═ ═ ⌬ ═ ═ ⬡")
                lines.append("")
            }
            
            let styledCat = converter.convert(category.name.uppercased(), to: style)
            let wrappedCats = wrapText(styledCat, maxVisualWidth: 10)
            for cLine in wrappedCats {
                lines.append("═━═[ ⏣ \(center(cLine, width: 10)) ⏣ ]═━═")
            }
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(dept.name.uppercased(), to: style)
                let wrappedDepts = wrapText(styledDept, maxVisualWidth: 12)
                for dLine in wrappedDepts {
                    lines.append("╔═[ ⚡︎ \(center(dLine, width: 12)) ]═╗")
                }
                
                for (itemIndex, item) in dept.items.enumerated() {
                    appendWrappedItem(
                        lines: &lines,
                        text: item.name.uppercased(),
                        bullet: "⌬ ",
                        continuationIndent: "  ",
                        maxVisualWidth: 24
                    )
                    for option in item.options {
                        if !option.detail.isEmpty {
                            appendWrappedItem(
                                lines: &lines,
                                text: option.detail,
                                bullet: "  ╟── ",
                                continuationIndent: "  ║   ",
                                maxVisualWidth: 24
                            )
                        }
                        if !option.price.isEmpty {
                            let wrappedPrice = wrapText(option.price, maxVisualWidth: 14)
                            for (pIdx, pLine) in wrappedPrice.enumerated() {
                                if pIdx == 0 && wrappedPrice.count == 1 {
                                    lines.append("  ╚═▶ [ \(pLine) ]")
                                } else if pIdx == 0 {
                                    lines.append("  ╚═▶ [ \(pLine)")
                                } else if pIdx == wrappedPrice.count - 1 {
                                    lines.append("        \(pLine) ]")
                                } else {
                                    lines.append("        \(pLine)")
                                }
                            }
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
    
    // MARK: - 3. Alchemical Sanctum (Strict <= 24 cols with Smart Wrapping)
    
    private static func formatAlchemicalSanctum(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        
        let rawTitle = document.title.isEmpty ? "HERMETIC VAULT" : document.title
        let styledTitle = converter.convert(rawTitle.uppercased(), to: fontStyle)
        
        lines.append("        ☉ ☽ ☿")
        appendWrappedBox(
            lines: &lines,
            text: styledTitle,
            topBorder: "╔══════════════════════╗",
            bottomBorder: "╚══════════════════════╝",
            leftGutter: "║   ༺ ",
            rightGutter: " ༻   ║",
            contentWidth: 10,
            centerLines: true
        )
        lines.append("        ᚛ ༒ ᚜")
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("      ᚛ ☉ ☽ ☿ ᚜")
                lines.append("")
            }
            
            let styledCat = converter.convert(category.name.uppercased(), to: fontStyle)
            let wrappedCats = wrapText(styledCat, maxVisualWidth: 10)
            for cLine in wrappedCats {
                lines.append("░▒▓ ༒ \(center(cLine, width: 10)) ༒ ▓▒░")
            }
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(dept.name.uppercased(), to: fontStyle)
                lines.append("        𓆩 𖤍 𓆪")
                appendWrappedBox(
                    lines: &lines,
                    text: styledDept,
                    topBorder: "╭───── ❖ ─────╮",
                    bottomBorder: "╰───── ❖ ─────╯",
                    leftGutter: "│ ",
                    rightGutter: " │",
                    contentWidth: 11,
                    centerLines: true
                )
                
                for (itemIndex, item) in dept.items.enumerated() {
                    appendWrappedItem(
                        lines: &lines,
                        text: item.name.uppercased(),
                        bullet: "✦ ",
                        continuationIndent: "  ",
                        maxVisualWidth: 24
                    )
                    for option in item.options {
                        if !option.detail.isEmpty {
                            appendWrappedItem(
                                lines: &lines,
                                text: option.detail,
                                bullet: "  ├─ ",
                                continuationIndent: "  │  ",
                                maxVisualWidth: 24
                            )
                        }
                        if !option.price.isEmpty {
                            appendWrappedItem(
                                lines: &lines,
                                text: option.price,
                                bullet: "  └─► ",
                                continuationIndent: "      ",
                                maxVisualWidth: 24
                            )
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
    
    // MARK: - 4. Engulfing Vortex (Strict <= 24 cols with Smart Wrapping)
    
    private static func formatEngulfingVortex(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        
        let rawTitle = document.title.isEmpty ? "VORTEX CONDUIT" : document.title
        let styledTitle = converter.convert(rawTitle.uppercased(), to: fontStyle)
        let wrappedTitles = wrapText(styledTitle, maxVisualWidth: 12)
        
        lines.append("░▒▓██████████████████▓▒░")
        for tLine in wrappedTitles {
            lines.append("▓▒  ༺ \(center(tLine, width: 12)) ༻  ▒▓")
        }
        lines.append("░▒▓██████████████████▓▒░")
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("▓▒░  ▲ ◈ ❖ ◈ ▲  ░▒▓")
                lines.append("")
            }
            
            let styledCat = converter.convert(category.name.uppercased(), to: fontStyle)
            let wrappedCats = wrapText(styledCat, maxVisualWidth: 10)
            for cLine in wrappedCats {
                lines.append("▓▒░ ◈ \(center(cLine, width: 10)) ◈ ░▒▓")
            }
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(dept.name.uppercased(), to: fontStyle)
                let wrappedDepts = wrapText(styledDept, maxVisualWidth: 10)
                for dLine in wrappedDepts {
                    lines.append("▓▒ ╭━━ \(center(dLine, width: 10)) ━━╮ ▒▓")
                }
                
                for (itemIndex, item) in dept.items.enumerated() {
                    let wrappedItems = wrapText(item.name.uppercased(), maxVisualWidth: 15)
                    for (idx, iLine) in wrappedItems.enumerated() {
                        let prefix = (idx == 0) ? "◈ " : "  "
                        let content = padRight("\(prefix)\(iLine)", width: 18)
                        lines.append("▓▒ \(content) ▒▓")
                    }
                    
                    for option in item.options {
                        if !option.detail.isEmpty {
                            let wrappedDetails = wrapText(option.detail, maxVisualWidth: 14)
                            for (idx, dLine) in wrappedDetails.enumerated() {
                                let prefix = (idx == 0) ? "  ┠ " : "  ┃ "
                                let content = padRight("\(prefix)\(dLine)", width: 18)
                                lines.append("▓▒ \(content) ▒▓")
                            }
                        }
                        if !option.price.isEmpty {
                            let wrappedPrices = wrapText(option.price, maxVisualWidth: 12)
                            for (idx, pLine) in wrappedPrices.enumerated() {
                                let prefix = (idx == 0) ? "  ┃ ➔ " : "  ┃   "
                                let content = padRight("\(prefix)\(pLine)", width: 18)
                                lines.append("▓▒ \(content) ▒▓")
                            }
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
    
    // MARK: - 5. Celestial Void (Strict <= 24 cols with Smart Wrapping)
    
    private static func formatCelestialVoid(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        let style = (fontStyle == .frakturBold) ? .cursiveBold : fontStyle
        
        let rawTitle = document.title.isEmpty ? "CELESTIAL REALM" : document.title
        let styledTitle = converter.convert(rawTitle.uppercased(), to: style)
        
        lines.append("        ★ ✵ ✧ ✦")
        lines.append("         ☾ ⋆ ☽")
        appendWrappedBox(
            lines: &lines,
            text: styledTitle,
            topBorder: "╭─── ✦ ─── ✦ ─── ✦ ───╮",
            bottomBorder: "╰──────────────────────╯",
            leftGutter: "│  ",
            rightGutter: "  │",
            contentWidth: 16,
            centerLines: true
        )
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("       ★ ⋆ ✦ ⋆ ★")
                lines.append("")
            }
            
            let styledCat = converter.convert(category.name.uppercased(), to: style)
            let wrappedCats = wrapText(styledCat, maxVisualWidth: 14)
            lines.append("★ ━━━━━━━━━━━━━━━━━━━━ ★")
            for cLine in wrappedCats {
                lines.append("    ༺ \(center(cLine, width: 14)) ༻")
            }
            lines.append("★ ━━━━━━━━━━━━━━━━━━━━ ★")
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(dept.name.uppercased(), to: style)
                let wrappedDepts = wrapText(styledDept, maxVisualWidth: 12)
                for dLine in wrappedDepts {
                    lines.append("╭── ☾ \(center(dLine, width: 12)) ☽ ──╮")
                }
                
                for (itemIndex, item) in dept.items.enumerated() {
                    appendWrappedItem(
                        lines: &lines,
                        text: item.name.uppercased(),
                        bullet: "✧ ",
                        continuationIndent: "  ",
                        maxVisualWidth: 24
                    )
                    for option in item.options {
                        if !option.detail.isEmpty {
                            appendWrappedItem(
                                lines: &lines,
                                text: option.detail,
                                bullet: "  ┠ ",
                                continuationIndent: "  ┃ ",
                                maxVisualWidth: 24
                            )
                        }
                        if !option.price.isEmpty {
                            appendWrappedItem(
                                lines: &lines,
                                text: option.price,
                                bullet: "  ┃ ➔ ",
                                continuationIndent: "  ┃   ",
                                maxVisualWidth: 24
                            )
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
    
    // MARK: - 6. Royal Baroque (Strict <= 24 cols with Smart Wrapping)
    
    private static func formatRoyalBaroque(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        
        let rawTitle = document.title.isEmpty ? "ROYAL VAULT" : document.title
        let styledTitle = converter.convert(rawTitle.uppercased(), to: fontStyle)
        
        lines.append("       ꧁ ༺ ♔ ༻ ꧂")
        appendWrappedBox(
            lines: &lines,
            text: styledTitle,
            topBorder: "  ╔══════════════════╗",
            bottomBorder: "  ╚══════════════════╝",
            leftGutter: "  ║   ",
            rightGutter: "   ║",
            contentWidth: 12,
            centerLines: true
        )
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("       ❧ ━ ❦ ━ ❧")
                lines.append("")
            }
            
            let styledCat = converter.convert(category.name.uppercased(), to: fontStyle)
            let wrappedCats = wrapText(styledCat, maxVisualWidth: 12)
            lines.append("❧ ━━━━━━━━━━━━━━━━━━━━ ❦")
            for cLine in wrappedCats {
                lines.append("     ꧁ \(center(cLine, width: 12)) ꧂")
            }
            lines.append("❧ ━━━━━━━━━━━━━━━━━━━━ ❦")
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(dept.name.uppercased(), to: fontStyle)
                lines.append("        𓆩 ♕ 𓆪")
                appendWrappedBox(
                    lines: &lines,
                    text: styledDept,
                    topBorder: "╭━━━ ♕ ━━━ ♕ ━━━╮",
                    bottomBorder: "╰━━━━━━━━━━━━━━━━━━━━╯",
                    leftGutter: "┃ ",
                    rightGutter: " ┃",
                    contentWidth: 16,
                    centerLines: true
                )
                
                for (itemIndex, item) in dept.items.enumerated() {
                    appendWrappedItem(
                        lines: &lines,
                        text: item.name.uppercased(),
                        bullet: "❖ ",
                        continuationIndent: "  ",
                        maxVisualWidth: 24
                    )
                    for option in item.options {
                        if !option.detail.isEmpty {
                            appendWrappedItem(
                                lines: &lines,
                                text: option.detail,
                                bullet: "  ├─ ",
                                continuationIndent: "  │  ",
                                maxVisualWidth: 24
                            )
                        }
                        if !option.price.isEmpty {
                            appendWrappedItem(
                                lines: &lines,
                                text: option.price,
                                bullet: "  └─ ",
                                continuationIndent: "     ",
                                maxVisualWidth: 24
                            )
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
    
    // MARK: - 7. Nordic Rune (Strict <= 24 cols with Smart Wrapping)
    
    private static func formatNordicRune(document: ParsedDocument, fontStyle: TypographyStyle) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        
        let rawTitle = document.title.isEmpty ? "VALHALLA VAULT" : document.title
        let styledTitle = converter.convert(rawTitle.uppercased(), to: fontStyle)
        let wrappedTitles = wrapText(styledTitle, maxVisualWidth: 12)
        
        lines.append("      ᚛ ᚠ ᚢ ᚦ ᚨ ᚱ ᚜")
        lines.append("  ╔══════════════════╗")
        for tLine in wrappedTitles {
            lines.append("  ║   \(center(tLine, width: 12))   ║")
        }
        lines.append("  ╚══════════════════╝")
        lines.append("      ᚛ ᚠ ᚢ ᚦ ᚨ ᚱ ᚜")
        lines.append("")
        
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                lines.append("      ᚛═══ ❖ ═══᚜")
                lines.append("")
            }
            
            let styledCat = converter.convert(category.name.uppercased(), to: fontStyle)
            let wrappedCats = wrapText(styledCat, maxVisualWidth: 10)
            for cLine in wrappedCats {
                lines.append("▓▒░ ᚛ \(center(cLine, width: 10)) ᚜ ░▒▓")
            }
            lines.append("")
            
            for dept in category.departments {
                let styledDept = converter.convert(dept.name.uppercased(), to: fontStyle)
                lines.append("        ⚔︎ ᚦ ⚔︎")
                appendWrappedBox(
                    lines: &lines,
                    text: styledDept,
                    topBorder: "┌───── ᚛ ᚜ ─────┐",
                    bottomBorder: "└───── ᚛ ᚜ ─────┘",
                    leftGutter: "│ ",
                    rightGutter: " │",
                    contentWidth: 13,
                    centerLines: true
                )
                
                for (itemIndex, item) in dept.items.enumerated() {
                    appendWrappedItem(
                        lines: &lines,
                        text: item.name.uppercased(),
                        bullet: "᚛ ",
                        continuationIndent: "  ",
                        maxVisualWidth: 24
                    )
                    for option in item.options {
                        if !option.detail.isEmpty {
                            appendWrappedItem(
                                lines: &lines,
                                text: option.detail,
                                bullet: "  ┠ ",
                                continuationIndent: "  ┃ ",
                                maxVisualWidth: 24
                            )
                        }
                        if !option.price.isEmpty {
                            appendWrappedItem(
                                lines: &lines,
                                text: option.price,
                                bullet: "  ┃ ➔ ",
                                continuationIndent: "  ┃   ",
                                maxVisualWidth: 24
                            )
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
    
    // MARK: - Universal Architectural Helpers
    
    public static func center(_ text: String, width: Int) -> String {
        let visualLen = TextWidthMetrics.visualColumnWidth(of: text)
        if visualLen >= width { return text }
        let totalPad = width - visualLen
        let leftPad = totalPad / 2
        let rightPad = totalPad - leftPad
        return String(repeating: " ", count: leftPad) + text + String(repeating: " ", count: rightPad)
    }
    
    public static func padRight(_ text: String, width: Int) -> String {
        let visualLen = TextWidthMetrics.visualColumnWidth(of: text)
        if visualLen >= width { return text }
        return text + String(repeating: " ", count: width - visualLen)
    }
    
    /// Wraps text into multiple lines such that each line has visualColumnWidth <= maxVisualWidth.
    /// Breaks across whole word boundaries first, cleanly falling back to character boundaries for oversized tokens.
    public static func wrapText(_ text: String, maxVisualWidth: Int) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        guard maxVisualWidth > 0 else { return [trimmed] }
        if TextWidthMetrics.visualColumnWidth(of: trimmed) <= maxVisualWidth {
            return [trimmed]
        }
        
        let words = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        var lines: [String] = []
        var currentLine = ""
        
        for word in words {
            let candidate = currentLine.isEmpty ? word : currentLine + " " + word
            if TextWidthMetrics.visualColumnWidth(of: candidate) <= maxVisualWidth {
                currentLine = candidate
            } else {
                if !currentLine.isEmpty {
                    lines.append(currentLine)
                    currentLine = ""
                }
                
                if TextWidthMetrics.visualColumnWidth(of: word) <= maxVisualWidth {
                    currentLine = word
                } else {
                    var chunk = ""
                    for char in word {
                        let testChunk = chunk + String(char)
                        if TextWidthMetrics.visualColumnWidth(of: testChunk) > maxVisualWidth {
                            if !chunk.isEmpty {
                                lines.append(chunk)
                            }
                            chunk = String(char)
                        } else {
                            chunk = testChunk
                        }
                    }
                    if !chunk.isEmpty {
                        currentLine = chunk
                    }
                }
            }
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines.isEmpty ? [trimmed] : lines
    }
    
    /// Appends text wrapped across multiple lines with a bullet on line 0 and aligned continuationIndent on lines 1+.
    public static func appendWrappedItem(
        lines: inout [String],
        text: String,
        bullet: String,
        continuationIndent: String,
        maxVisualWidth: Int = 24
    ) {
        let bulletWidth = TextWidthMetrics.visualColumnWidth(of: bullet)
        let availWidth = max(maxVisualWidth - bulletWidth, 8)
        let wrapped = wrapText(text, maxVisualWidth: availWidth)
        for (idx, wLine) in wrapped.enumerated() {
            if idx == 0 {
                lines.append("\(bullet)\(wLine)")
            } else {
                lines.append("\(continuationIndent)\(wLine)")
            }
        }
    }
    
    /// Appends a symmetrically framed box that vertically expands to fit multi-line wrapped text without truncation.
    public static func appendWrappedBox(
        lines: inout [String],
        text: String,
        topBorder: String,
        bottomBorder: String,
        leftGutter: String,
        rightGutter: String,
        contentWidth: Int,
        centerLines: Bool = true
    ) {
        let wrapped = wrapText(text, maxVisualWidth: contentWidth)
        lines.append(topBorder)
        for wLine in wrapped {
            let inner = centerLines ? center(wLine, width: contentWidth) : padRight(wLine, width: contentWidth)
            lines.append("\(leftGutter)\(inner)\(rightGutter)")
        }
        lines.append(bottomBorder)
    }
    
    /// Legacy fallback helper for single-line truncation when explicitly required.
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
