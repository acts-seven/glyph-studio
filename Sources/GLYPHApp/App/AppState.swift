import SwiftUI
import GLYPHCore

#if os(macOS)
import AppKit
#else
import UIKit
#endif

@Observable
@MainActor
public final class AppState {
    public var currentText: String = """
░░▒▒▓▓████████████▓▓▒▒░░
▓  ༺ 𝔉𝔒𝔒𝔇  𝔙𝔄𝔘𝔏𝔗 ༻  ▓
░░▒▒▓▓████████████▓▓▒▒░░

◈ EXTRA VIRGIN OLIVE OIL
  ┠ 500 mL (x12)
  ┃ ➔ $102.00 [$8.50/u]
  ┠ 3 L Tin (x4)
  ┃ ➔ $120.00 [$30/u]
  ┠ 20 L Drum (x1)
  ┃ ➔ $165.00
  ╍╍╍╍╍ ❖ ╍╍╍╍╍

◈ JASMINE RICE A-GRADE
  ┠ 1 kg Bag (x10)
  ┃ ➔ $28.00 [$2.80/u]
  ┠ 5 kg Bag (x4)
  ┃ ➔ $44.00 [$11/u]
  ┠ 25 kg Sack (x1)
  ┃ ➔ $42.50
"""
    
    public var activeStyle: TypographyStyle = .frakturBold
    public var selectedTheme: ArchitecturalTheme = .obeliskGothic
    public var isLiveTyping: Bool = false
    public var isDarkMode: Bool = true
    public var isMonospacePreview: Bool = false
    public var simulatedWidth: CGFloat = 393 // iPhone 16 Pro default
    public var showCopiedBanner: Bool = false
    public var bannerMessage: String = "Copied to Clipboard"
    public var showPresetGallery: Bool = false
    
    public var lineReports: [LineSafetyReport] {
        WrapToleranceSensor.inspect(text: currentText)
    }
    
    public var dangerCount: Int {
        lineReports.filter { $0.status == .danger }.count
    }
    
    public func copyToClipboard() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(currentText, forType: .string)
        #else
        UIPasteboard.general.string = currentText
        #endif
        
        showNotificationBanner(message: "Copied to Clipboard! Ready for Signal")
    }
    
    public func readFromClipboard() -> String? {
        #if os(macOS)
        return NSPasteboard.general.string(forType: .string)
        #else
        return UIPasteboard.general.string
        #endif
    }
    
    public func pasteAndArchitect() {
        guard let clipboardText = readFromClipboard(), !clipboardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showNotificationBanner(message: "Clipboard is empty!")
            return
        }
        
        let parsed = SemanticHierarchyParser.parse(rawText: clipboardText)
        currentText = HierarchicalThemeFormatter.format(
            document: parsed,
            theme: selectedTheme,
            fontStyle: activeStyle
        )
        showNotificationBanner(message: "✨ Auto-Architected from Clipboard!")
    }
    
    public func autoArchitect(theme: ArchitecturalTheme? = nil) {
        let themeToUse = theme ?? selectedTheme
        let parsed = SemanticHierarchyParser.parse(rawText: currentText)
        currentText = HierarchicalThemeFormatter.format(
            document: parsed,
            theme: themeToUse,
            fontStyle: activeStyle
        )
        showNotificationBanner(message: "✨ Formatted with \(themeToUse.rawValue)")
    }
    
    /// Intelligently wraps any text lines in the editor exceeding maxColumns across whole words with matching structural indentation.
    public func wrapCurrentTextToSafeWidth(maxColumns: Int = 24) {
        let lines = currentText.components(separatedBy: .newlines)
        var newLines: [String] = []
        for line in lines {
            let colWidth = TextWidthMetrics.visualColumnWidth(of: line)
            if colWidth <= maxColumns {
                newLines.append(line)
            } else {
                let leadingSpaces = line.prefix(while: { $0 == " " || $0 == "\t" })
                let indent = String(leadingSpaces)
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                
                var bullet = ""
                var continuationIndent = indent + "  "
                let candidateBullets = ["◈ ", "⌬ ", "✦ ", "❖ ", "✧ ", "᚛ ", "• ", "- ", "* "]
                for b in candidateBullets {
                    if trimmed.hasPrefix(b) {
                        bullet = b
                        continuationIndent = indent + String(repeating: " ", count: TextWidthMetrics.visualColumnWidth(of: b))
                        break
                    }
                }
                let branchBullets = ["├─ ", "┠ ", "╟── ", "├ ", "│ ", "┃ "]
                for br in branchBullets {
                    if trimmed.hasPrefix(br) {
                        bullet = br
                        continuationIndent = indent + "│ "
                        break
                    }
                }
                
                let contentWithoutBullet = bullet.isEmpty ? trimmed : String(trimmed.dropFirst(bullet.count))
                let availableWidth = max(maxColumns - TextWidthMetrics.visualColumnWidth(of: indent + bullet), 8)
                let wrapped = HierarchicalThemeFormatter.wrapText(contentWithoutBullet, maxVisualWidth: availableWidth)
                
                for (idx, wLine) in wrapped.enumerated() {
                    if idx == 0 {
                        newLines.append(indent + bullet + wLine)
                    } else {
                        newLines.append(continuationIndent + wLine)
                    }
                }
            }
        }
        currentText = newLines.joined(separator: "\n")
        showNotificationBanner(message: "↩ Wrapped to ≤\(maxColumns) Columns")
    }
    
    public func applyProceduralRoll(vibe: ProceduralVibe) {
        currentText = ProceduralMonolithGenerator.generate(
            title: "FLASH ACCESS",
            bodyLines: ["ALLOCATION: 20 SLOTS", "CUTOFF: MIDNIGHT", "RESERVE: DM @ADMIN"],
            vibe: vibe,
            fontStyle: activeStyle
        )
        showNotificationBanner(message: "🎲 Rolled \(vibe.rawValue)")
    }
    
    public func applyPreset(_ preset: SignalPostPreset) {
        currentText = preset.render().trimmingCharacters(in: .whitespacesAndNewlines)
        showNotificationBanner(message: "Loaded '\(preset.title)'")
    }
    
    public func applyRenderedPreset(_ rendered: String, title: String) {
        currentText = rendered.trimmingCharacters(in: .whitespacesAndNewlines)
        showNotificationBanner(message: "Loaded '\(title)'")
    }
    
    public func transcodeAllText(to style: TypographyStyle) {
        currentText = UnicodeFontConverter.shared.convert(currentText, to: style)
        showNotificationBanner(message: "Transcoded to \(style.rawValue)")
    }
    
    public func insertGlyph(_ glyph: String) {
        currentText.append(glyph + " ")
    }
    
    private func showNotificationBanner(message: String) {
        bannerMessage = message
        #if canImport(UIKit) && !os(watchOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            showCopiedBanner = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                self.showCopiedBanner = false
            }
        }
    }
}
