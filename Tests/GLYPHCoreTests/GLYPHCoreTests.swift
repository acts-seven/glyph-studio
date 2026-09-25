import Testing
import Foundation
@testable import GLYPHCore

@Suite("GLYPH Core Craftsmanship & Invariant Tests")
struct GLYPHCoreTests {
    
    // MARK: - 1. Procedural Monolith Box Geometry Invariants
    
    @Test("Procedural Monolith Title Box Geometry under Fuzzed Long Input")
    func testProceduralMonolithBoxGeometryWithLongTitle() {
        let longTitle = "EXTREMELY LONG TITULAR MONOLITH BOUNDARY BLOWOUT TEST STRING"
        for vibe in ProceduralVibe.allCases {
            let card = ProceduralMonolithGenerator.generate(
                title: longTitle,
                bodyLines: ["LINE ONE WITH SUBSTANTIAL LENGTH EXCEEDING USUAL LIMITS", "LINE TWO"],
                vibe: vibe,
                fontStyle: .frakturBold
            )
            
            let lines = card.components(separatedBy: .newlines)
            #expect(!lines.isEmpty)
            
            // Verify box header, middle, and bottom
            if let boxTopIndex = lines.firstIndex(where: { $0.contains("╭━━━━━━━━━━━━━━━━━━━━╮") }) {
                let boxTop = lines[boxTopIndex]
                let boxMid = lines[boxTopIndex + 1]
                let boxBot = lines[boxTopIndex + 2]
                
                let topWidth = TextWidthMetrics.visualColumnWidth(of: boxTop)
                let midWidth = TextWidthMetrics.visualColumnWidth(of: boxMid)
                let botWidth = TextWidthMetrics.visualColumnWidth(of: boxBot)
                
                // Box must be exactly 22 columns wide on all 3 lines
                #expect(topWidth == 22, "Top border width must be 22, got \(topWidth)")
                #expect(midWidth == 22, "Middle border width must be 22 for vibe \(vibe), got \(midWidth)")
                #expect(botWidth == 22, "Bottom border width must be 22, got \(botWidth)")
            } else {
                Issue.record("Box border not found in procedural monolith")
            }
            
            // Verify that NO line in the card exceeds 24 visual columns (Signal safe zone)
            for (idx, line) in lines.enumerated() {
                let colWidth = TextWidthMetrics.visualColumnWidth(of: line)
                #expect(colWidth <= 24, "Line \(idx) in vibe \(vibe) exceeded 24 cols: '\(line)' (width: \(colWidth))")
            }
        }
    }
    
    // MARK: - 2. Unicode Variation Selector Precedence
    
    @Test("Unicode Variation Selector U+FE0E width evaluation")
    func testUnicodeVariationSelectorPrecedence() {
        // U+26A1 is High Voltage Sign (emoji presentation default = 2 cols)
        // With U+FE0E (text presentation), it MUST evaluate to 1 col
        let lightningText = "⚡︎"
        let swordText = "⚔︎"
        
        let lightningWidth = TextWidthMetrics.visualColumnWidth(of: lightningText)
        let swordWidth = TextWidthMetrics.visualColumnWidth(of: swordText)
        
        #expect(lightningWidth == 1, "⚡︎ with U+FE0E must evaluate to 1 col, got \(lightningWidth)")
        #expect(swordWidth == 1, "⚔︎ with U+FE0E must evaluate to 1 col, got \(swordWidth)")
    }
    
    // MARK: - 3. Architectural Themes Column Invariants (<= 24 cols)
    
    @Test("All Architectural Themes strictly obey <= 24 columns")
    func testArchitecturalThemesColumnSafety() {
        let sampleMenu = """
        # PACIFIC RIM OYSTER VAULT
        1. LIVE MOLLUSKS
        1.1 Kumamoto Pacific
        - Dozen Shucked $48.00 [$4/u]
        - Two Dozen Tray $90.00
        1.2 Belon European Flat
        - Half Dozen $32.00
        RESERVE: DM @CHEF_ADMIN
        PAYMENT: USDC / CASH
        """
        
        let doc = SemanticHierarchyParser.parse(rawText: sampleMenu)
        #expect(doc.title == "PACIFIC RIM OYSTER VAULT")
        #expect(doc.categories.count == 1)
        #expect(doc.operationalNotes.count == 2)
        
        let allThemes: [ArchitecturalTheme] = [
            .obeliskGothic, .cyberMatrix, .alchemicalSanctum,
            .engulfingVortex, .celestialVoid, .royalBaroque, .nordicRune
        ]
        
        for theme in allThemes {
            let rendered = HierarchicalThemeFormatter.format(document: doc, theme: theme, fontStyle: .frakturBold)
            let reports = WrapToleranceSensor.inspect(text: rendered)
            let hazards = reports.filter { $0.status == .danger }
            
            #expect(hazards.isEmpty, "Theme \(theme.rawValue) produced \(hazards.count) danger lines exceeding 28 columns")
            
            for report in reports {
                #expect(report.visualColumns <= 24, "Theme \(theme.rawValue) line exceeded 24 cols: '\(report.content)' (width \(report.visualColumns))")
            }
        }
    }
    
    // MARK: - 4. Semantic Hierarchy Parsing Heuristics
    
    @Test("Semantic Hierarchy Parser extracts title, categories, and prices accurately")
    func testSemanticHierarchyParser() {
        let input = """
        # GUILD COLD STORAGE
        ## 1. BUTCHERY CUTS
        ### 1.1 WAGYU A5 RIB CAP
        - 250g Steak : $85.00
        - 500g Roast : $160.00
        STATUS: IN STOCK
        """
        
        let doc = SemanticHierarchyParser.parse(rawText: input)
        #expect(doc.title == "GUILD COLD STORAGE")
        #expect(doc.categories.count == 1)
        #expect(doc.categories.first?.name == "BUTCHERY CUTS")
        #expect(doc.operationalNotes.contains("STATUS: IN STOCK"))
    }
    
    // MARK: - 5. Smart Word-Boundary Text Wrapping
    
    @Test("wrapText splits long strings across word boundaries without truncation")
    func testWrapTextWordBoundarySplitting() {
        let text = "BREAD (FRESH LOCAL BAKERY)"
        let wrapped = HierarchicalThemeFormatter.wrapText(text, maxVisualWidth: 20)
        #expect(wrapped.count == 2)
        #expect(wrapped[0] == "BREAD (FRESH LOCAL")
        #expect(wrapped[1] == "BAKERY)")
        for line in wrapped {
            #expect(TextWidthMetrics.visualColumnWidth(of: line) <= 20)
        }
    }
    
    // MARK: - 6. User Screenshot Grocery List: Zero-Data-Loss Invariant
    
    @Test("User grocery list is fully included with zero truncation across all themes")
    func testZeroDataLossAndWrappingOnUserGroceryList() {
        let groceryList = """
        Normal Grocery List
        General
        Items
        Store: Local Supermarket
        Payment/Pickup: Card / Cash
        Bread (Fresh Local Bakery)
        Dish Sponges / Scourers
        Eggs (1 Dozen, Large)
        Full-Cream Milk (2 Litre)
        Light Milk (1-Litre Bottle)
        Instant Coffee / Tea Bags
        Butter (Salted, 250g)
        Pending / Next Trip
        Paper Towels (Check Stock)
        Fruit Juice (6-Pack)
        """
        
        let doc = SemanticHierarchyParser.parse(rawText: groceryList)
        let allThemes: [ArchitecturalTheme] = [
            .obeliskGothic, .cyberMatrix, .alchemicalSanctum,
            .engulfingVortex, .celestialVoid, .royalBaroque, .nordicRune
        ]
        
        // Critical keywords that must NEVER be truncated
        let mustPreserveWords = [
            "SUPERMARKET", "BAKERY", "SCOURERS", "LARGE",
            "LITRE", "BOTTLE", "BAGS", "250G", "TRIP", "STOCK"
        ]
        
        for theme in allThemes {
            let rendered = HierarchicalThemeFormatter.format(document: doc, theme: theme, fontStyle: .smallCaps)
            
            // 1. Invariant: ZERO lines may exceed 24 columns
            let reports = WrapToleranceSensor.inspect(text: rendered)
            for report in reports {
                #expect(
                    report.visualColumns <= 24,
                    "Theme \(theme.rawValue) exceeded 24 cols: '\(report.content)' (width \(report.visualColumns))"
                )
            }
            
            // 2. Invariant: ZERO ellipsis truncation artifacts
            #expect(!rendered.contains("…"), "Theme \(theme.rawValue) contained truncation ellipsis '…'")
            #expect(!rendered.contains("..."), "Theme \(theme.rawValue) contained truncation dots '...'")
            
            // 3. Invariant: All content must be included
            let uppercaseRendered = rendered.uppercased()
            for word in mustPreserveWords {
                #expect(
                    uppercaseRendered.contains(word),
                    "Theme \(theme.rawValue) lost keyword '\(word)' due to truncation"
                )
            }
        }
    }
}
