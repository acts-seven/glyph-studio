import Foundation
import GLYPHCore

// =============================================================================
// MARK: - GLYPH Command-Line Tool & IPC Engine
// =============================================================================

@main
struct GlyphCLI {
    
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())
        
        guard let first = args.first else {
            printHelp()
            exit(0)
        }
        
        switch first {
        case "-h", "--help", "help":
            printHelp()
            
        case "-v", "--version", "version":
            print("GLYPH Studio CLI & Plugin Engine v\(GlyphPluginService.shared.version)")
            
        case "list-presets", "presets":
            handleListPresets(args: Array(args.dropFirst()))
            
        case "render-preset", "render":
            handleRenderPreset(args: Array(args.dropFirst()))
            
        case "format":
            handleFormat(args: Array(args.dropFirst()))
            
        case "validate":
            handleValidate(args: Array(args.dropFirst()))
            
        case "monolith":
            handleMonolith(args: Array(args.dropFirst()))
            
        case "themes":
            handleListThemes()
            
        case "plugin":
            handlePlugin(args: Array(args.dropFirst()))
            
        case "rpc":
            handleRPC()
            
        default:
            fputs("Unknown command: '\(first)'. Run 'glyph --help' for usage.\n", stderr)
            exit(1)
        }
    }
    
    // MARK: - Subcommand Handlers
    
    private static func handleListPresets(args: [String]) {
        var isJSON = false
        var categoryFilter: String? = nil
        
        var i = 0
        while i < args.count {
            let arg = args[i]
            if arg == "--json" {
                isJSON = true
            } else if arg == "--category" || arg == "-c", i + 1 < args.count {
                i += 1
                categoryFilter = args[i]
            }
            i += 1
        }
        
        var list = PresetsLibrary.allPresets
        if let cat = categoryFilter, !cat.isEmpty {
            list = list.filter { $0.category.localizedCaseInsensitiveContains(cat) }
        }
        
        if isJSON {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(list), let str = String(data: data, encoding: .utf8) {
                print(str)
            }
            return
        }
        
        print("◈ GLYPH PRESET REPOSITORY [\(list.count) Presets Available]\n")
        var currentCat = ""
        for p in list {
            if p.category != currentCat {
                currentCat = p.category
                print("─── [ \(currentCat) ] ─────────────────────────")
            }
            print("  • \(p.id.padding(toLength: 22, withPad: " ", startingAt: 0)) │ \(p.title)")
            if !p.variables.isEmpty {
                print("    Variables: \(p.variables.joined(separator: ", "))")
            }
        }
        print("\nTo render a preset, run: glyph render-preset <id> [--var KEY=VALUE]")
    }
    
    private static func handleRenderPreset(args: [String]) {
        guard let id = args.first, !id.hasPrefix("-") else {
            fputs("Error: Missing <preset-id>. Usage: glyph render-preset <preset-id> [--var KEY=VALUE] [--width 24]\n", stderr)
            exit(1)
        }
        
        guard let preset = PresetsLibrary.preset(for: id) else {
            fputs("Error: Unknown preset ID '\(id)'. Run 'glyph list-presets' to inspect library.\n", stderr)
            exit(1)
        }
        
        var variables: [String: String] = [:]
        var targetWidth = 24
        
        var i = 1
        while i < args.count {
            let arg = args[i]
            if (arg == "--var" || arg == "-v"), i + 1 < args.count {
                i += 1
                let pair = args[i]
                if let eqIndex = pair.firstIndex(of: "=") {
                    let k = String(pair[..<eqIndex])
                    let v = String(pair[pair.index(after: eqIndex)...])
                    variables[k] = v
                }
            } else if (arg == "--width" || arg == "-w"), i + 1 < args.count {
                i += 1
                if let w = Int(args[i]) {
                    targetWidth = w
                }
            }
            i += 1
        }
        
        let output = preset.render(with: variables, maxColumns: targetWidth)
        print(output)
    }
    
    private static func handleFormat(args: [String]) {
        var filePath: String? = nil
        var themeName = "Obelisk Apex"
        var densityName = "Fraktur Bold"
        var targetWidth = 24
        
        var i = 0
        while i < args.count {
            let arg = args[i]
            if (arg == "--theme" || arg == "-t"), i + 1 < args.count {
                i += 1
                themeName = args[i]
            } else if (arg == "--style" || arg == "-s"), i + 1 < args.count {
                i += 1
                densityName = args[i]
            } else if (arg == "--width" || arg == "-w"), i + 1 < args.count {
                i += 1
                if let w = Int(args[i]) { targetWidth = w }
            } else if !arg.hasPrefix("-") && filePath == nil {
                filePath = arg
            }
            i += 1
        }
        
        let text: String
        if let path = filePath {
            guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
                fputs("Error: Could not read file at '\(path)'\n", stderr)
                exit(1)
            }
            text = content
        } else {
            text = readStdin()
        }
        
        let req = GlyphPluginRequest(
            action: .formatText,
            rawText: text,
            theme: themeName,
            density: densityName,
            targetColumns: targetWidth
        )
        let res = GlyphPluginService.shared.handle(request: req)
        if let rendered = res.renderedText {
            print(rendered)
        } else {
            fputs("Formatting failed: \(res.error ?? "Unknown error")\n", stderr)
            exit(1)
        }
    }
    
    private static func handleValidate(args: [String]) {
        var filePath: String? = nil
        var targetWidth = 24
        var isJSON = false
        
        var i = 0
        while i < args.count {
            let arg = args[i]
            if arg == "--json" {
                isJSON = true
            } else if (arg == "--width" || arg == "-w"), i + 1 < args.count {
                i += 1
                if let w = Int(args[i]) { targetWidth = w }
            } else if !arg.hasPrefix("-") && filePath == nil {
                filePath = arg
            }
            i += 1
        }
        
        let text: String
        if let path = filePath {
            guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
                fputs("Error: Could not read file at '\(path)'\n", stderr)
                exit(1)
            }
            text = content
        } else {
            text = readStdin()
        }
        
        let result = GlyphPluginService.shared.validateTextLayout(text, maxColumns: targetWidth)
        
        if isJSON {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(result), let str = String(data: data, encoding: .utf8) {
                print(str)
            }
            exit(result.isSafe ? 0 : 2)
        }
        
        if result.isSafe {
            print("✓ PASS: All lines satisfy mobile width constraint (Max width: \(result.maxVisualWidth) <= \(targetWidth) cols)")
            exit(0)
        } else {
            print("✗ FAIL: \(result.offendingLineIndices.count) line(s) violate mobile width limit (\(targetWidth) cols):")
            for issue in result.issues {
                print("  • \(issue)")
            }
            exit(2)
        }
    }
    
    private static func handleMonolith(args: [String]) {
        var title = "SIGNAL BROADCAST"
        var vibe = "Alchemical"
        
        var i = 0
        while i < args.count {
            let arg = args[i]
            if (arg == "--title" || arg == "-t"), i + 1 < args.count {
                i += 1
                title = args[i]
            } else if (arg == "--style" || arg == "-s"), i + 1 < args.count {
                i += 1
                vibe = args[i]
            }
            i += 1
        }
        
        let req = GlyphPluginRequest(
            action: .generateMonolith,
            monolithTitle: title,
            monolithStyle: vibe
        )
        let res = GlyphPluginService.shared.handle(request: req)
        if let rendered = res.renderedText {
            print(rendered)
        }
    }
    
    private static func handleListThemes() {
        print("Architectural Themes:")
        for t in ArchitecturalTheme.allCases {
            print("  • \(t.rawValue)")
        }
        print("\nTypography Styles:")
        for s in TypographyStyle.allCases {
            print("  • \(s.rawValue)")
        }
    }
    
    private static func handlePlugin(args: [String]) {
        var jsonString: String? = nil
        
        var i = 0
        while i < args.count {
            let arg = args[i]
            if arg == "--json", i + 1 < args.count {
                i += 1
                jsonString = args[i]
            }
            i += 1
        }
        
        let payload = jsonString ?? readStdin()
        let responseJSON = GlyphPluginService.shared.handleJSON(payload)
        print(responseJSON)
    }
    
    /// Persistent JSON-RPC daemon loop reading line-by-line over stdin/stdout
    private static func handleRPC() {
        let outputHandle = FileHandle.standardOutput
        
        // Notify host daemon that GLYPH RPC is ready
        let readyNotice = "{\"jsonrpc\":\"2.0\",\"method\":\"ready\",\"params\":{\"version\":\"\(GlyphPluginService.shared.version)\"}}\n"
        if let data = readyNotice.data(using: .utf8) {
            outputHandle.write(data)
        }
        
        while let line = readLine() {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            
            let res = GlyphPluginService.shared.handleJSON(trimmed)
            if let outData = (res + "\n").data(using: .utf8) {
                outputHandle.write(outData)
            }
        }
    }
    
    private static func readStdin() -> String {
        let data = FileHandle.standardInput.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private static func printHelp() {
        let help = """
        GLYPH STUDIO CLI & PLUGIN ENGINE
        Aesthetic typography, structural ASCII monoliths, and mobile-safe Signal presets.

        USAGE:
          glyph <command> [options]

        COMMANDS:
          list-presets               List available Signal post presets [--category <cat>] [--json]
          render-preset <id>         Render a preset with variable values [--var KEY=VAL] [--width 24]
          format [<file>]            Format structured text into aesthetic layout [--theme <name>] [--width 24]
          validate [<file>]          Check whether text conforms to mobile chat width limits [--width 24] [--json]
          monolith                   Generate a procedural ASCII monolith banner [--title <text>] [--style <vibe>]
          themes                     List available themes and typography styles
          plugin                     Execute a one-shot JSON plugin request from stdin or --json '<payload>'
          rpc                        Launch persistent line-delimited JSON-RPC loop over stdin/stdout

        EXAMPLES:
          glyph list-presets --category wholesale
          glyph render-preset food_vault --var PRICE_OIL_DRUM="$180.00"
          glyph format notes.txt --theme "Cyber Conduit"
          glyph validate broadcast.txt --width 24
          cat request.json | glyph plugin
          glyph rpc
        """
        print(help)
    }
}
