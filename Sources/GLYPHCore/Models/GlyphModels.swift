import Foundation

public struct GlyphCategory: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let sfSymbol: String
    public let glyphs: [String]
    
    public init(id: String, name: String, sfSymbol: String, glyphs: [String]) {
        self.id = id
        self.name = name
        self.sfSymbol = sfSymbol
        self.glyphs = glyphs
    }
}

public struct PresetTemplate: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let category: String
    public let content: String
    
    public init(id: String, title: String, category: String, content: String) {
        self.id = id
        self.title = title
        self.category = category
        self.content = content
    }
}
