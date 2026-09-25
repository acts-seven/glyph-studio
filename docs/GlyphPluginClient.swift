import Foundation

// =============================================================================
// MARK: - GLYPH Plugin Client for Signal Auto Poster
// =============================================================================
// Drop this file into `Sources/SignalMacDaemonLib/Services/GlyphPluginClient.swift`
// when ready to integrate GLYPH into Signal Auto Poster.
// Supports both in-process GLYPHCore calls and subprocess `glyph` CLI fallback.
// =============================================================================

public enum GlyphClientMode: Sendable {
    case inProcess
    case subprocess(executablePath: String)
}

public actor GlyphPluginClient {
    public static let shared = GlyphPluginClient()
    
    private var mode: GlyphClientMode = .inProcess
    
    public init(mode: GlyphClientMode = .inProcess) {
        self.mode = mode
    }
    
    public func setMode(_ mode: GlyphClientMode) {
        self.mode = mode
    }
    
    // MARK: - High-Level API
    
    /// Fetches all available mobile-safe Signal presets.
    public func listPresets(category: String? = nil) async throws -> [GlyphPresetSummary] {
        let req = GlyphPluginRequestDTO(action: "list_presets", category: category)
        let res = try await execute(request: req)
        return res.presets ?? []
    }
    
    /// Renders a preset by its unique ID with variable substitutions and column wrapping.
    public func renderPreset(id: String, variables: [String: String] = [:], maxColumns: Int = 24) async throws -> String {
        let req = GlyphPluginRequestDTO(
            action: "render_preset",
            presetId: id,
            variables: variables,
            targetColumns: maxColumns
        )
        let res = try await execute(request: req)
        return res.renderedText ?? ""
    }
    
    /// Formats unstructured draft text into an avant-garde hierarchical layout.
    public func formatText(rawText: String, theme: String = "Obelisk Apex", style: String = "Fraktur Bold", maxColumns: Int = 24) async throws -> String {
        let req = GlyphPluginRequestDTO(
            action: "format_text",
            rawText: rawText,
            theme: theme,
            density: style,
            targetColumns: maxColumns
        )
        let res = try await execute(request: req)
        return res.renderedText ?? ""
    }
    
    /// Validates whether a message strictly satisfies the mobile chat bubble column budget.
    public func validateLayout(text: String, maxColumns: Int = 24) async throws -> GlyphValidationDTO {
        let req = GlyphPluginRequestDTO(
            action: "validate_layout",
            rawText: text,
            targetColumns: maxColumns
        )
        let res = try await execute(request: req)
        guard let val = res.validation else {
            throw GlyphPluginError.missingPayload
        }
        return val
    }
    
    // MARK: - Core Execution Dispatcher
    
    private func execute(request: GlyphPluginRequestDTO) async throws -> GlyphPluginResponseDTO {
        switch mode {
        case .inProcess:
            #if canImport(GLYPHCore)
            return try executeInProcess(request: request)
            #else
            // Fallback to subprocess if GLYPHCore is not linked at compile time
            return try await executeSubprocess(request: request, executablePath: "/usr/local/bin/glyph")
            #endif
            
        case .subprocess(let path):
            return try await executeSubprocess(request: request, executablePath: path)
        }
    }
    
    #if canImport(GLYPHCore)
    private func executeInProcess(request: GlyphPluginRequestDTO) throws -> GlyphPluginResponseDTO {
        let encoder = JSONEncoder()
        let reqData = try encoder.encode(request)
        let jsonStr = String(data: reqData, encoding: .utf8) ?? "{}"
        
        let resStr = GLYPHCore.GlyphPluginService.shared.handleJSON(jsonStr)
        guard let resData = resStr.data(using: .utf8) else {
            throw GlyphPluginError.invalidResponse
        }
        return try JSONDecoder().decode(GlyphPluginResponseDTO.self, from: resData)
    }
    #endif
    
    private func executeSubprocess(request: GlyphPluginRequestDTO, executablePath: String) async throws -> GlyphPluginResponseDTO {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let process = Process()
                    let binURL: URL = {
                        if FileManager.default.fileExists(atPath: executablePath) {
                            return URL(fileURLWithPath: executablePath)
                        }
                        // Check common locations
                        let candidates = [
                            "/usr/local/bin/glyph",
                            "/opt/homebrew/bin/glyph",
                            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".local/bin/glyph").path
                        ]
                        for c in candidates where FileManager.default.fileExists(atPath: c) {
                            return URL(fileURLWithPath: c)
                        }
                        return URL(fileURLWithPath: executablePath)
                    }()
                    
                    process.executableURL = binURL
                    process.arguments = ["plugin"]
                    
                    let stdinPipe = Pipe()
                    let stdoutPipe = Pipe()
                    let stderrPipe = Pipe()
                    
                    process.standardInput = stdinPipe
                    process.standardOutput = stdoutPipe
                    process.standardError = stderrPipe
                    
                    try process.run()
                    
                    let reqData = try JSONEncoder().encode(request)
                    stdinPipe.fileHandleForWriting.write(reqData)
                    try stdinPipe.fileHandleForWriting.close()
                    
                    let outData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                    process.waitUntilExit()
                    
                    guard process.terminationStatus == 0 else {
                        let errData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                        let errMsg = String(data: errData, encoding: .utf8) ?? "Subprocess failed with code \(process.terminationStatus)"
                        continuation.resume(throwing: GlyphPluginError.processFailed(errMsg))
                        return
                    }
                    
                    let response = try JSONDecoder().decode(GlyphPluginResponseDTO.self, from: outData)
                    continuation.resume(returning: response)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// =============================================================================
// MARK: - DTO Models (Standalone & Decoupled)
// =============================================================================

public struct GlyphPluginRequestDTO: Codable, Sendable {
    public let action: String
    public var presetId: String?
    public var category: String?
    public var variables: [String: String]?
    public var rawText: String?
    public var theme: String?
    public var density: String?
    public var targetColumns: Int?
    
    public init(
        action: String,
        presetId: String? = nil,
        category: String? = nil,
        variables: [String: String]? = nil,
        rawText: String? = nil,
        theme: String? = nil,
        density: String? = nil,
        targetColumns: Int? = 24
    ) {
        self.action = action
        self.presetId = presetId
        self.category = category
        self.variables = variables
        self.rawText = rawText
        self.theme = theme
        self.density = density
        self.targetColumns = targetColumns
    }
}

public struct GlyphPluginResponseDTO: Codable, Sendable {
    public let id: String?
    public let success: Bool
    public let error: String?
    public let presets: [GlyphPresetSummary]?
    public let renderedText: String?
    public let validation: GlyphValidationDTO?
    public let version: String?
}

public struct GlyphPresetSummary: Identifiable, Codable, Sendable {
    public let id: String
    public let title: String
    public let category: String
    public let description: String
    public let tags: [String]
    public let variables: [String]
}

public struct GlyphValidationDTO: Codable, Sendable {
    public let isSafe: Bool
    public let maxVisualWidth: Int
    public let targetColumns: Int
    public let offendingLineIndices: [Int]
    public let safeWrappedText: String
    public let issues: [String]
}

public enum GlyphPluginError: LocalizedError, Sendable {
    case missingPayload
    case invalidResponse
    case processFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .missingPayload: return "GLYPH Plugin returned an empty payload."
        case .invalidResponse: return "Failed to parse GLYPH Plugin response."
        case .processFailed(let msg): return "GLYPH subprocess failed: \(msg)"
        }
    }
}
