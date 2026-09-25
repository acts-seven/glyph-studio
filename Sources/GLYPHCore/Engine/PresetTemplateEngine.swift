import Foundation

/// Structured metadata for a template variable placeholder in a preset.
public struct PresetVariableInfo: Sendable, Codable, Hashable, Identifiable {
    public var id: String { key }
    public let key: String
    public let defaultValue: String?
    public let isRequired: Bool
    
    public init(key: String, defaultValue: String? = nil, isRequired: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
        self.isRequired = isRequired
    }
}

/// High-performance, zero-data-loss template engine for Signal post presets.
/// Supports `{{KEY}}`, `{{ KEY }}`, and default fallbacks `{{KEY:-DEFAULT_VALUE}}`.
/// Performs automated, visually-aligned line wrapping to guarantee compliance with mobile column budgets.
public struct PresetTemplateEngine: Sendable {
    
    // Regular expression matching:
    // 1. {{KEY}}
    // 2. {{ KEY }}
    // 3. {{KEY:-DEFAULT_VALUE}}
    // 4. {{ KEY:-DEFAULT_VALUE }}
    private static let placeholderRegex: NSRegularExpression? = {
        let pattern = #"\{\{\s*([A-Za-z0-9_]+)(?::-(.*?))?\s*\}\}"#
        return try? NSRegularExpression(pattern: pattern, options: [])
    }()
    
    /// Interpolates variable keys formatted as `{{KEY}}` or `{{KEY:-DEFAULT}}` with supplied values.
    /// If any line exceeds `maxColumns` (default 24 columns for Signal bubble safety),
    /// it automatically wraps at word boundaries with aligned indentation and preserved list bullets.
    public static func render(
        template: String,
        variables: [String: String] = [:],
        maxColumns: Int = 24
    ) -> String {
        guard let regex = placeholderRegex else { return template }
        
        let nsString = template as NSString
        let matches = regex.matches(in: template, range: NSRange(location: 0, length: nsString.length))
        
        var processed = template
        // Replace in reverse order so string character offsets remain valid
        for match in matches.reversed() {
            guard match.numberOfRanges >= 2 else { continue }
            let fullRange = match.range(at: 0)
            let keyRange = match.range(at: 1)
            let key = nsString.substring(with: keyRange)
            
            var defaultValue: String? = nil
            if match.numberOfRanges >= 3 && match.range(at: 2).location != NSNotFound {
                defaultValue = nsString.substring(with: match.range(at: 2))
            }
            
            // Check provided variables (case-insensitive key lookup fallback)
            let providedValue: String? = {
                if let direct = variables[key] { return direct }
                if let lower = variables[key.lowercased()] { return lower }
                if let upper = variables[key.uppercased()] { return upper }
                return nil
            }()
            
            let replacement = providedValue ?? defaultValue ?? ""
            if let swiftRange = Range(fullRange, in: processed) {
                processed.replaceSubrange(swiftRange, with: replacement)
            }
        }
        
        // Wrap safety on all lines
        return enforceColumnBudget(processed, maxColumns: maxColumns)
    }
    
    /// Discovers all unique variable placeholder keys in a template string.
    public static func extractVariables(from template: String) -> [String] {
        return extractVariableInfos(from: template).map(\.key)
    }
    
    /// Discovers all variable placeholders with their default values and requirements.
    public static func extractVariableInfos(from template: String) -> [PresetVariableInfo] {
        guard let regex = placeholderRegex else { return [] }
        let nsString = template as NSString
        let matches = regex.matches(in: template, range: NSRange(location: 0, length: nsString.length))
        
        var seen = Set<String>()
        var results: [PresetVariableInfo] = []
        
        for match in matches {
            guard match.numberOfRanges >= 2 else { continue }
            let key = nsString.substring(with: match.range(at: 1))
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            
            var defaultValue: String? = nil
            if match.numberOfRanges >= 3 && match.range(at: 2).location != NSNotFound {
                defaultValue = nsString.substring(with: match.range(at: 2))
            }
            
            results.append(PresetVariableInfo(
                key: key,
                defaultValue: defaultValue,
                isRequired: defaultValue == nil
            ))
        }
        
        return results
    }
    
    /// Extracts a default dictionary of key-value pairs from template declarations.
    public static func extractDefaultValues(from template: String) -> [String: String] {
        var defaults: [String: String] = [:]
        for info in extractVariableInfos(from: template) {
            if let def = info.defaultValue {
                defaults[info.key] = def
            }
        }
        return defaults
    }
    
    /// Strict visual column wrapping preserving box-drawing trees, bullets, and indentation.
    public static func enforceColumnBudget(_ text: String, maxColumns: Int) -> String {
        let lines = text.components(separatedBy: .newlines)
        var safeLines: [String] = []
        
        for line in lines {
            let width = TextWidthMetrics.visualColumnWidth(of: line)
            if width <= maxColumns {
                safeLines.append(line)
            } else {
                let leadingSpaces = line.prefix(while: { $0 == " " || $0 == "\t" })
                let indent = String(leadingSpaces)
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                
                var bullet = ""
                var continuationIndent = indent + "  "
                let candidateBullets = ["◈ ", "⌬ ", "✦ ", "❖ ", "✧ ", "᚛ ", "• ", "- ", "* ", "➔ "]
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
                        safeLines.append(indent + bullet + wLine)
                    } else {
                        safeLines.append(continuationIndent + wLine)
                    }
                }
            }
        }
        
        return safeLines.joined(separator: "\n")
    }
}
