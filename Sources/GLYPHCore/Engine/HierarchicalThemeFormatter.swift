import Foundation

public struct HierarchicalThemeFormatter: Sendable {
    
    /// Formats a parsed document into the exact, museum-grade layout matching the screenshot
    public static func format(document: ParsedDocument, fontStyle: TypographyStyle = .frakturBold) -> String {
        var lines: [String] = []
        let converter = UnicodeFontConverter.shared
        
        // 1. Master Apex Obelisk (Title)
        let rawTitle = document.title.isEmpty ? "MASTER CATALOG" : document.title
        let styledTitle = converter.convert(rawTitle.uppercased(), to: fontStyle)
        
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
        
        // 2. Iterate Categories
        for (catIndex, category) in document.categories.enumerated() {
            if catIndex > 0 {
                // Inter-category transition totem
                lines.append("        ▲   ▲")
                lines.append("       ▲ ◈ ▲ ◈ ▲")
                lines.append("      ◄ ❖ ⚔︎ ❖ ►")
                lines.append("       ▼ ◈ ▼ ◈ ▼")
                lines.append("        ▼   ▼")
                lines.append("")
            }
            
            // Category Shaded Band
            let styledCat = converter.convert(category.name.uppercased(), to: fontStyle)
            lines.append("░░▒▒▓▓████████████▓▓▒▒░░")
            lines.append("▓  ༺ \(center(styledCat, width: 14)) ༻  ▓")
            lines.append("░░▒▒▓▓████████████▓▓▒▒░░")
            lines.append("")
            
            // Iterate Departments
            for dept in category.departments {
                let styledDept = converter.convert(dept.name.uppercased(), to: fontStyle)
                
                lines.append("       𓆩 ⚡︎ 𓆪")
                lines.append("╭━━━━━━━━━━━━━━━━━━━━╮")
                lines.append("┃ \(center(styledDept, width: 18)) ┃")
                lines.append("╰━━━━━━━━━━━━━━━━━━━━╯")
                
                // Iterate Items
                for (itemIndex, item) in dept.items.enumerated() {
                    lines.append("◈ \(item.name.uppercased())")
                    
                    for (optIndex, option) in item.options.enumerated() {
                        let isLast = (optIndex == item.options.count - 1)
                        if !option.detail.isEmpty {
                            lines.append("  ┠ \(option.detail)")
                        }
                        if !option.price.isEmpty {
                            lines.append("  ┃ ➔ \(option.price)")
                        }
                    }
                    
                    if itemIndex < dept.items.count - 1 {
                        lines.append("  ╍╍╍╍╍ ❖ ╍╍╍╍╍")
                    }
                }
                lines.append("")
            }
        }
        
        // 3. Outro Inverted Apex
        lines.append("      ░▒▓█ 𖤍 █▓▒░")
        lines.append("    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀")
        lines.append("     ╲ \(center(styledTitle, width: 11)) ╱")
        lines.append("      ╲ ═════════ ╱")
        lines.append("       ╲  𖤍 𖤍 𖤍  ╱")
        lines.append("        ╲ ░▒▓▒░ ╱")
        lines.append("         ╲ ⚔︎ ⚔︎ ╲")
        lines.append("          ╲ ◈ ╱")
        lines.append("           ╲ ╱")
        lines.append("            ▼")
        
        return lines.joined(separator: "\n")
    }
    
    private static func center(_ text: String, width: Int) -> String {
        let visualLen = TextWidthMetrics.visualColumnWidth(of: text)
        if visualLen >= width { return text }
        let totalPad = width - visualLen
        let leftPad = totalPad / 2
        let rightPad = totalPad - leftPad
        return String(repeating: " ", count: leftPad) + text + String(repeating: " ", count: rightPad)
    }
}
