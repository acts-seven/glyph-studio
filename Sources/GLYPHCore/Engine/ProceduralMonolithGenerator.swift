import Foundation

public enum ProceduralVibe: String, CaseIterable, Identifiable, Sendable {
    case alchemical = "Alchemical"
    case tibetan    = "Tibetan"
    case cyberHex   = "Cyber Hex"
    case audioWave  = "Audio Wave"
    case occultVoid = "Occult Void"
    case galactic   = "Galactic"
    
    public var id: String { rawValue }
}

public struct ProceduralMonolithGenerator: Sendable {
    
    public static func generate(
        title: String,
        bodyLines: [String] = [],
        vibe: ProceduralVibe = .alchemical,
        fontStyle: TypographyStyle = .frakturBold
    ) -> String {
        let maxCols = 22
        let styledTitle = UnicodeFontConverter.shared.convert(title.uppercased(), to: fontStyle)
        
        let headerCrown: String
        let topSwirl: String
        let bottomSwirl: String
        let divider: String
        
        switch vibe {
        case .alchemical:
            headerCrown = "        🜏        "
            topSwirl    = "   ╭── ☉ ──╮    "
            divider     = "╍╍╍ 🜚 ❖ 🜚 ╍╍╍"
            bottomSwirl = "   ╰── ☿ ──╯    "
            
        case .tibetan:
            headerCrown = "  ༺ ༄ ༓ ࿇ ༓ ༄ ༻  "
            topSwirl    = " ༼  ░▒▓ 𖤍 ▓▒░  ༽ "
            divider     = "┈┈━ ༓ ࿇ ༓ ━┈┈"
            bottomSwirl = " ༼  ░▒▓ 𖤍 ▓▒░  ༽ "
            
        case .cyberHex:
            headerCrown = "    ⏣ ━━━━ ⏣    "
            topSwirl    = "   ╱  ░▒▓▒░  ╲   "
            divider     = "━━━ ⏣ ⎔ ⏣ ━━━"
            bottomSwirl = "   ╲  ░▒▓▒░  ╱   "
            
        case .audioWave:
            headerCrown = " ⡇⢸⣼⣹ ❖ ⣸⣨⣅⢸⡇ "
            topSwirl    = " ⣿ ░▒▓█▓▒░ ⣿ "
            divider     = "⡇⢸⣼⣹ ❖ ⣸⣨⣅⢸⡇"
            bottomSwirl = " ⣿ ░▒▓█▓▒░ ⣿ "
            
        case .occultVoid:
            headerCrown = "   𓆩 ⚡︎ ━━ ⚡︎ 𓆪   "
            topSwirl    = "  :  *  .  :  *  "
            divider     = "░▒▓█ 𓆩 𖤍 𓆪 █▓▒░"
            bottomSwirl = "  :  *  .  :  *  "
            
        case .galactic:
            headerCrown = "   .  :  *  .  :  *   "
            topSwirl    = "  . ꩜ ༄ 𖦹 ୭ ๑ 𖦹 ༄ ꩜ .  "
            divider     = " ░▒▓█ 𖦹 𖤍 𖦹 █▓▒░ "
            bottomSwirl = "  . ꩜ ༄ 𖦹 ୭ ๑ 𖦹 ༄ ꩜ .  "
        }
        
        var card: [String] = []
        card.append(headerCrown.trimmingCharacters(in: .newlines))
        card.append(topSwirl.trimmingCharacters(in: .newlines))
        
        // Symmetrical Title Monolith Box (Guaranteed 22 columns)
        let fittedTitle = HierarchicalThemeFormatter.fitText(styledTitle, maxVisualWidth: 18)
        card.append("╭━━━━━━━━━━━━━━━━━━━━╮")
        card.append("┃ \(centerText(fittedTitle, width: 18)) ┃")
        card.append("╰━━━━━━━━━━━━━━━━━━━━╯")
        
        if !bodyLines.isEmpty {
            card.append(divider)
            for line in bodyLines {
                let fittedLine = HierarchicalThemeFormatter.fitText(line.uppercased(), maxVisualWidth: 19)
                card.append("◈ \(fittedLine)")
            }
        }
        
        card.append(divider)
        card.append(bottomSwirl.trimmingCharacters(in: .newlines))
        
        return card.joined(separator: "\n")
    }
    
    private static func centerText(_ text: String, width: Int) -> String {
        let visualLen = TextWidthMetrics.visualColumnWidth(of: text)
        if visualLen >= width { return text }
        let totalPad = width - visualLen
        let leftPad = totalPad / 2
        let rightPad = totalPad - leftPad
        return String(repeating: " ", count: leftPad) + text + String(repeating: " ", count: rightPad)
    }
}
