import Foundation

// =============================================================================
// MARK: - Plugin Action & Data Models
// =============================================================================

/// Supported actions for the GLYPH Signal Auto Poster plugin engine.
public enum GlyphPluginAction: String, Codable, Sendable {
    case ping = "ping"
    case listPresets = "list_presets"
    case getPreset = "get_preset"
    case renderPreset = "render_preset"
    case listThemes = "list_themes"
    case formatText = "format_text"
    case validateLayout = "validate_layout"
    case generateMonolith = "generate_monolith"
    case wrapText = "wrap_text"
}

/// Request payload sent to the GLYPH plugin engine.
public struct GlyphPluginRequest: Codable, Sendable {
    public var id: String?
    public var action: GlyphPluginAction
    
    // Preset parameters
    public var presetId: String?
    public var category: String?
    public var variables: [String: String]?
    
    // Formatting & wrapping parameters
    public var rawText: String?
    public var theme: String?
    public var density: String?
    public var targetColumns: Int?
    
    // Monolith generator parameters
    public var monolithTitle: String?
    public var monolithStyle: String?
    public var monolithSeed: UInt64?
    
    public init(
        id: String? = UUID().uuidString,
        action: GlyphPluginAction,
        presetId: String? = nil,
        category: String? = nil,
        variables: [String: String]? = nil,
        rawText: String? = nil,
        theme: String? = nil,
        density: String? = nil,
        targetColumns: Int? = 24,
        monolithTitle: String? = nil,
        monolithStyle: String? = nil,
        monolithSeed: UInt64? = nil
    ) {
        self.id = id
        self.action = action
        self.presetId = presetId
        self.category = category
        self.variables = variables
        self.rawText = rawText
        self.theme = theme
        self.density = density
        self.targetColumns = targetColumns
        self.monolithTitle = monolithTitle
        self.monolithStyle = monolithStyle
        self.monolithSeed = monolithSeed
    }
}

/// Validation metrics and safety diagnostics for mobile message layouts.
public struct GlyphLayoutValidationResult: Codable, Sendable {
    public let isSafe: Bool
    public let maxVisualWidth: Int
    public let targetColumns: Int
    public let offendingLineIndices: [Int]
    public let safeWrappedText: String
    public let issues: [String]
    
    public init(
        isSafe: Bool,
        maxVisualWidth: Int,
        targetColumns: Int,
        offendingLineIndices: [Int],
        safeWrappedText: String,
        issues: [String]
    ) {
        self.isSafe = isSafe
        self.maxVisualWidth = maxVisualWidth
        self.targetColumns = targetColumns
        self.offendingLineIndices = offendingLineIndices
        self.safeWrappedText = safeWrappedText
        self.issues = issues
    }
}

/// Response payload returned by the GLYPH plugin engine.
public struct GlyphPluginResponse: Codable, Sendable {
    public let id: String?
    public let success: Bool
    public let error: String?
    
    // Payloads
    public let presets: [SignalPostPreset]?
    public let preset: SignalPostPreset?
    public let renderedText: String?
    public let themes: [String]?
    public let categories: [String]?
    public let validation: GlyphLayoutValidationResult?
    public let version: String
    
    public init(
        id: String? = nil,
        success: Bool,
        error: String? = nil,
        presets: [SignalPostPreset]? = nil,
        preset: SignalPostPreset? = nil,
        renderedText: String? = nil,
        themes: [String]? = nil,
        categories: [String]? = nil,
        validation: GlyphLayoutValidationResult? = nil,
        version: String = "1.0.0"
    ) {
        self.id = id
        self.success = success
        self.error = error
        self.presets = presets
        self.preset = preset
        self.renderedText = renderedText
        self.themes = themes
        self.categories = categories
        self.validation = validation
        self.version = version
    }
    
    public static func failure(id: String?, message: String) -> GlyphPluginResponse {
        return GlyphPluginResponse(id: id, success: false, error: message)
    }
}

// =============================================================================
// MARK: - JSON-RPC 2.0 Types
// =============================================================================

public struct JSONRPCRequest: Codable, Sendable {
    public let jsonrpc: String
    public let id: AnyCodableValue?
    public let method: String
    public let params: GlyphPluginRequest?
    
    public init(jsonrpc: String = "2.0", id: AnyCodableValue? = nil, method: String, params: GlyphPluginRequest? = nil) {
        self.jsonrpc = jsonrpc
        self.id = id
        self.method = method
        self.params = params
    }
}

public struct JSONRPCResponse: Codable, Sendable {
    public let jsonrpc: String
    public let id: AnyCodableValue?
    public let result: GlyphPluginResponse?
    public let error: JSONRPCError?
    
    public init(jsonrpc: String = "2.0", id: AnyCodableValue?, result: GlyphPluginResponse?, error: JSONRPCError? = nil) {
        self.jsonrpc = jsonrpc
        self.id = id
        self.result = result
        self.error = error
    }
}

public struct JSONRPCError: Codable, Sendable {
    public let code: Int
    public let message: String
    
    public init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}

public enum AnyCodableValue: Codable, Sendable, Equatable {
    case string(String)
    case int(Int)
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
        } else if let strVal = try? container.decode(String.self) {
            self = .string(strVal)
        } else {
            self = .null
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let s): try container.encode(s)
        case .int(let i): try container.encode(i)
        case .null: try container.encodeNil()
        }
    }
}

// =============================================================================
// MARK: - Glyph Plugin Service
// =============================================================================

/// First-class plugin engine service designed for direct Swift consumption
/// and daemon CLI IPC (JSON / JSON-RPC).
public final class GlyphPluginService: @unchecked Sendable {
    public static let shared = GlyphPluginService()
    
    public let version = "1.0.0"
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()
    
    public init() {}
    
    // MARK: - Core Request Dispatcher
    
    public func handle(request: GlyphPluginRequest) -> GlyphPluginResponse {
        let id = request.id
        let targetCols = request.targetColumns ?? 24
        
        switch request.action {
        case .ping:
            return GlyphPluginResponse(
                id: id,
                success: true,
                renderedText: "PONG - GLYPH Plugin Engine v\(version)",
                version: version
            )
            
        case .listPresets:
            var list = PresetsLibrary.allPresets
            if let cat = request.category, !cat.isEmpty {
                list = list.filter { $0.category.localizedCaseInsensitiveContains(cat) }
            }
            return GlyphPluginResponse(
                id: id,
                success: true,
                presets: list,
                categories: PresetsLibrary.categories,
                version: version
            )
            
        case .getPreset:
            guard let presetId = request.presetId, !presetId.isEmpty else {
                return .failure(id: id, message: "Missing presetId in request")
            }
            guard let found = PresetsLibrary.preset(for: presetId) else {
                return .failure(id: id, message: "Preset not found with id: \(presetId)")
            }
            return GlyphPluginResponse(
                id: id,
                success: true,
                preset: found,
                version: version
            )
            
        case .renderPreset:
            guard let presetId = request.presetId, !presetId.isEmpty else {
                return .failure(id: id, message: "Missing presetId in request")
            }
            guard let found = PresetsLibrary.preset(for: presetId) else {
                return .failure(id: id, message: "Preset not found with id: \(presetId)")
            }
            let vars = request.variables ?? [:]
            let rendered = found.render(with: vars, maxColumns: targetCols)
            return GlyphPluginResponse(
                id: id,
                success: true,
                preset: found,
                renderedText: rendered,
                version: version
            )
            
        case .listThemes:
            let themeNames = ArchitecturalTheme.allCases.map(\.rawValue)
            return GlyphPluginResponse(
                id: id,
                success: true,
                themes: themeNames,
                version: version
            )
            
        case .formatText:
            guard let raw = request.rawText else {
                return .failure(id: id, message: "Missing rawText in request")
            }
            let theme: ArchitecturalTheme = {
                if let t = request.theme {
                    for candidate in ArchitecturalTheme.allCases {
                        if candidate.rawValue.localizedCaseInsensitiveContains(t) {
                            return candidate
                        }
                    }
                }
                return .obeliskGothic
            }()
            let fontStyle: TypographyStyle = {
                if let s = request.density { // can pass style or density
                    for candidate in TypographyStyle.allCases {
                        if candidate.rawValue.localizedCaseInsensitiveContains(s) {
                            return candidate
                        }
                    }
                }
                return .frakturBold
            }()
            
            let doc = SemanticHierarchyParser.parse(rawText: raw)
            let formatted = HierarchicalThemeFormatter.format(document: doc, theme: theme, fontStyle: fontStyle)
            let safeWrapped = PresetTemplateEngine.enforceColumnBudget(formatted, maxColumns: targetCols)
            return GlyphPluginResponse(
                id: id,
                success: true,
                renderedText: safeWrapped,
                version: version
            )
            
        case .validateLayout:
            guard let text = request.rawText else {
                return .failure(id: id, message: "Missing rawText in request")
            }
            let validation = validateTextLayout(text, maxColumns: targetCols)
            return GlyphPluginResponse(
                id: id,
                success: true,
                validation: validation,
                version: version
            )
            
        case .generateMonolith:
            let title = request.monolithTitle ?? "TRANSMISSION"
            let vibe: ProceduralVibe = {
                if let s = request.monolithStyle {
                    for v in ProceduralVibe.allCases {
                        if v.rawValue.localizedCaseInsensitiveContains(s) {
                            return v
                        }
                    }
                }
                return .alchemical
            }()
            let lines = request.rawText?.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty } ?? []
            let monolith = ProceduralMonolithGenerator.generate(
                title: title,
                bodyLines: lines,
                vibe: vibe
            )
            return GlyphPluginResponse(
                id: id,
                success: true,
                renderedText: monolith,
                version: version
            )
            
        case .wrapText:
            guard let text = request.rawText else {
                return .failure(id: id, message: "Missing rawText in request")
            }
            let wrapped = PresetTemplateEngine.enforceColumnBudget(text, maxColumns: targetCols)
            return GlyphPluginResponse(
                id: id,
                success: true,
                renderedText: wrapped,
                version: version
            )
        }
    }
    
    // MARK: - Layout Validation Logic
    
    public func validateTextLayout(_ text: String, maxColumns: Int = 24) -> GlyphLayoutValidationResult {
        let lines = text.components(separatedBy: .newlines)
        var maxObservedWidth = 0
        var offendingLines: [Int] = []
        var issues: [String] = []
        
        for (index, line) in lines.enumerated() {
            let width = TextWidthMetrics.visualColumnWidth(of: line)
            if width > maxObservedWidth {
                maxObservedWidth = width
            }
            if width > maxColumns {
                offendingLines.append(index)
                issues.append("Line \(index + 1) width (\(width) cols) exceeds target budget (\(maxColumns) cols)")
            }
        }
        
        let safeText = PresetTemplateEngine.enforceColumnBudget(text, maxColumns: maxColumns)
        let isSafe = offendingLines.isEmpty
        
        return GlyphLayoutValidationResult(
            isSafe: isSafe,
            maxVisualWidth: maxObservedWidth,
            targetColumns: maxColumns,
            offendingLineIndices: offendingLines,
            safeWrappedText: safeText,
            issues: issues
        )
    }
    
    // MARK: - JSON & JSON-RPC Handling
    
    /// Processes a single JSON string request and returns a serialized JSON string response.
    public func handleJSON(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8) else {
            let err = GlyphPluginResponse.failure(id: nil, message: "Invalid UTF-8 input string")
            return (try? String(data: jsonEncoder.encode(err), encoding: .utf8)) ?? "{}"
        }
        
        // 1. Try decoding standard GlyphPluginRequest
        if let directReq = try? jsonDecoder.decode(GlyphPluginRequest.self, from: data) {
            let res = handle(request: directReq)
            if let outData = try? jsonEncoder.encode(res), let outStr = String(data: outData, encoding: .utf8) {
                return outStr
            }
        }
        
        // 2. Try decoding JSON-RPC 2.0 Request
        if let rpcReq = try? jsonDecoder.decode(JSONRPCRequest.self, from: data) {
            let action = GlyphPluginAction(rawValue: rpcReq.method) ?? .ping
            var req = rpcReq.params ?? GlyphPluginRequest(action: action)
            req.action = action
            
            let res = handle(request: req)
            let rpcRes = JSONRPCResponse(jsonrpc: "2.0", id: rpcReq.id, result: res)
            if let outData = try? jsonEncoder.encode(rpcRes), let outStr = String(data: outData, encoding: .utf8) {
                return outStr
            }
        }
        
        // 3. Fallback error
        let err = GlyphPluginResponse.failure(id: nil, message: "Malformed JSON payload: must conform to GlyphPluginRequest or JSONRPCRequest")
        return (try? String(data: jsonEncoder.encode(err), encoding: .utf8)) ?? "{}"
    }
}
