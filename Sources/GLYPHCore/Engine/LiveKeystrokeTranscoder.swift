import Foundation

public final class LiveKeystrokeTranscoder: @unchecked Sendable {
    public static let shared = LiveKeystrokeTranscoder()
    
    public var activeStyle: TypographyStyle = .frakturBold
    public var isLiveTypingEnabled: Bool = true
    
    private init() {}
    
    public func transcodeKey(char: Character) -> String {
        guard isLiveTypingEnabled else { return String(char) }
        return UnicodeFontConverter.shared.convert(String(char), to: activeStyle)
    }
    
    public func transcodeBlock(text: String, style: TypographyStyle) -> String {
        return UnicodeFontConverter.shared.convert(text, to: style)
    }
}
