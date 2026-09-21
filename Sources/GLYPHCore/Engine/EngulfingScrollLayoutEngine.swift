import Foundation

public struct EngulfingGutterStyle: Sendable {
    public let leftGutter: String
    public let rightGutter: String
    public let interNode: String
    public let maxContentWidth: Int
    
    public init(leftGutter: String, rightGutter: String, interNode: String, maxContentWidth: Int = 14) {
        self.leftGutter = leftGutter
        self.rightGutter = rightGutter
        self.interNode = interNode
        self.maxContentWidth = maxContentWidth
    }
    
    public static let alchemical = EngulfingGutterStyle(
        leftGutter: " 🜁 │ ",
        rightGutter: " │ 🜄",
        interNode: " 🜃 │ ─── ༓ ࿇ ༓ ─── │ 🜂"
    )
    
    public static let cyber = EngulfingGutterStyle(
        leftGutter: " ▌ ▞ │ ",
        rightGutter: " │ ▚ ▐",
        interNode: " ▌ ▞ ┠── 𖦹 ꩜ 𖦹 ──┨ ▚ ▐"
    )
    
    public static let gothic = EngulfingGutterStyle(
        leftGutter: " ║ ░ ",
        rightGutter: " ░ ║",
        interNode: " ╠═ 𓆩 ⚡︎ ━━ ⚡︎ 𓆪 ═╣"
    )
}

public struct EngulfingScrollLayoutEngine: Sendable {
    
    public static func wrapList(
        sections: [(title: String, items: [(name: String, price: String)])],
        style: EngulfingGutterStyle
    ) -> String {
        var output: [String] = []
        
        for (secIndex, section) in sections.enumerated() {
            if secIndex > 0 {
                output.append(style.interNode)
            }
            
            let paddedTitle = padToWidth("◈ " + section.title.uppercased(), width: style.maxContentWidth)
            output.append("\(style.leftGutter)\(paddedTitle)\(style.rightGutter)")
            
            for item in section.items {
                let nameLine = padToWidth("  ┠ \(item.name)", width: style.maxContentWidth)
                let priceLine = padToWidth("  ┃ ➔ \(item.price)", width: style.maxContentWidth)
                output.append("\(style.leftGutter)\(nameLine)\(style.rightGutter)")
                output.append("\(style.leftGutter)\(priceLine)\(style.rightGutter)")
            }
        }
        
        return output.joined(separator: "\n")
    }
    
    private static func padToWidth(_ text: String, width: Int) -> String {
        let currentWidth = TextWidthMetrics.visualColumnWidth(of: text)
        if currentWidth >= width { return text }
        return text + String(repeating: " ", count: width - currentWidth)
    }
}
