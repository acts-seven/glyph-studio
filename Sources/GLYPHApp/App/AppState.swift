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
    public var isLiveTyping: Bool = true
    public var isDarkMode: Bool = true
    public var simulatedWidth: CGFloat = 393 // iPhone 16 Pro default
    public var showCopiedBanner: Bool = false
    
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
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showCopiedBanner = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                self.showCopiedBanner = false
            }
        }
    }
    
    public func applyProceduralRoll(vibe: ProceduralVibe) {
        currentText = ProceduralMonolithGenerator.generate(
            title: "FLASH ACCESS",
            bodyLines: ["ALLOCATION: 20 SLOTS", "CUTOFF: MIDNIGHT", "RESERVE: DM @ADMIN"],
            vibe: vibe,
            fontStyle: activeStyle
        )
    }
    
    public func autoArchitect() {
        let parsed = SemanticHierarchyParser.parse(rawText: currentText)
        currentText = HierarchicalThemeFormatter.format(document: parsed, fontStyle: activeStyle)
    }
    
    public func insertGlyph(_ glyph: String) {
        currentText.append(glyph + " ")
    }
}
