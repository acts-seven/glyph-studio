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
    
    // MARK: - 7. Exhaustive Verification of All 40 Presets (<= 24 cols)
    
    @Test("All 40 Presets in catalog render cleanly within <= 24 columns")
    func testAll40PresetsObey24ColumnInvariant() {
        let all = PresetsLibrary.allPresets
        #expect(all.count >= 40, "Expected at least 40 presets, found \(all.count)")
        
        for preset in all {
            let rendered = preset.render()
            let lines = rendered.components(separatedBy: .newlines)
            
            #expect(!lines.isEmpty, "Preset \(preset.id) rendered empty string")
            
            for (idx, line) in lines.enumerated() {
                let colWidth = TextWidthMetrics.visualColumnWidth(of: line)
                #expect(
                    colWidth <= 24,
                    "Preset '\(preset.id)' (\(preset.title)) line \(idx) exceeded 24 cols: '\(line)' (width: \(colWidth))"
                )
            }
            
            // Verify no unresolved variable placeholders when default values are present
            let remainingPlaceholders = PresetTemplateEngine.extractVariables(from: rendered)
            #expect(
                remainingPlaceholders.isEmpty,
                "Preset '\(preset.id)' has unresolved placeholders in rendered output: \(remainingPlaceholders)"
            )
        }
    }
    
    // MARK: - 8. Variable Substitution & Word-Boundary Wrap Fuzzing
    
    @Test("PresetTemplateEngine safely wraps excessively long injected variables")
    func testPresetTemplateEngineFuzzingWithLongVariables() {
        let preset = PresetsLibrary.preset(for: "food_vault")!
        let fuzzedVariables: [String: String] = [
            "PRICE_OIL_DRUM": "$9,999,999,999.00 / METRIC TON HIGH-SEAS DRUM",
            "PRICE_RICE": "$1,250.00 / 500-KG CONTAINER FREIGHT",
            "PRICE_FLOUR": "$880.00 / WHOLESALE PALLET"
        ]
        
        let rendered = preset.render(with: fuzzedVariables, maxColumns: 24)
        let lines = rendered.components(separatedBy: .newlines)
        
        for (idx, line) in lines.enumerated() {
            let colWidth = TextWidthMetrics.visualColumnWidth(of: line)
            #expect(
                colWidth <= 24,
                "Fuzzed preset line \(idx) exceeded 24 cols: '\(line)' (width: \(colWidth))"
            )
        }
        
        // Assert all critical numbers from fuzzed variables are preserved without truncation
        #expect(rendered.contains("9,999,999,999.00"))
        #expect(rendered.contains("HIGH-SEAS"))
        #expect(rendered.contains("1,250.00"))
        #expect(rendered.contains("880.00"))
    }
    
    // MARK: - 9. GLYPHPluginEngine In-Process & JSON-RPC Verification
    
    @Test("GlyphPluginService handles in-process requests with high fidelity")
    func testGlyphPluginServiceInProcess() {
        let service = GlyphPluginService.shared
        
        // 1. Ping
        let pingReq = GlyphPluginRequest(action: .ping)
        let pingRes = service.handle(request: pingReq)
        #expect(pingRes.success == true)
        #expect(pingRes.renderedText?.contains("PONG") == true)
        
        // 2. List Presets
        let listReq = GlyphPluginRequest(action: .listPresets)
        let listRes = service.handle(request: listReq)
        #expect(listRes.success == true)
        #expect((listRes.presets?.count ?? 0) >= 40)
        
        // 3. Render Preset
        let renderReq = GlyphPluginRequest(
            action: .renderPreset,
            presetId: "speakeasy_cipher",
            variables: ["DOOR_CODE": "#9999*", "CIPHER": "MIDNIGHT SUN"]
        )
        let renderRes = service.handle(request: renderReq)
        #expect(renderRes.success == true)
        #expect(renderRes.renderedText?.contains("#9999*") == true)
        #expect(renderRes.renderedText?.contains("MIDNIGHT SUN") == true)
        
        // 4. Validate Layout
        let safeText = "◈ LINE ONE\n◈ LINE TWO"
        let valReq = GlyphPluginRequest(action: .validateLayout, rawText: safeText)
        let valRes = service.handle(request: valReq)
        #expect(valRes.success == true)
        #expect(valRes.validation?.isSafe == true)
        
        let wideText = "◈ THIS IS AN EXTREMELY WIDE LINE THAT BLOWS PAST 24 COLUMNS DEFINITELY"
        let valBadReq = GlyphPluginRequest(action: .validateLayout, rawText: wideText, targetColumns: 24)
        let valBadRes = service.handle(request: valBadReq)
        #expect(valBadRes.success == true)
        #expect(valBadRes.validation?.isSafe == false)
        #expect(valBadRes.validation?.offendingLineIndices.contains(0) == true)
        #expect(valBadRes.validation?.safeWrappedText.contains("◈ THIS IS AN") == true)
    }
    
    @Test("GlyphPluginService handles JSON-RPC 2.0 payloads correctly")
    func testGlyphPluginServiceJSONRPC() {
        let jsonRPCRequest = """
        {
            "jsonrpc": "2.0",
            "id": "req-42",
            "method": "render_preset",
            "params": {
                "action": "render_preset",
                "presetId": "vip_access",
                "variables": {
                    "TIER": "EMERALD CITADEL",
                    "STATUS": "AUTHORIZED"
                }
            }
        }
        """
        
        let responseString = GlyphPluginService.shared.handleJSON(jsonRPCRequest)
        #expect(!responseString.isEmpty)
        #expect(responseString.contains("\"jsonrpc\":\"2.0\""))
        #expect(responseString.contains("req-42"))
        #expect(responseString.contains("EMERALD CITADEL"))
        #expect(responseString.contains("AUTHORIZED"))
    }
}

