import Foundation
import NaturalLanguage

public struct ParsedDocument: Sendable {
    public var title: String
    public var categories: [ParsedCategory]
    public var operationalNotes: [String]
    
    public init(title: String = "", categories: [ParsedCategory] = [], operationalNotes: [String] = []) {
        self.title = title
        self.categories = categories
        self.operationalNotes = operationalNotes
    }
}

public struct ParsedCategory: Sendable {
    public var name: String
    public var departments: [ParsedDepartment]
    
    public init(name: String, departments: [ParsedDepartment] = []) {
        self.name = name
        self.departments = departments
    }
}

public struct ParsedDepartment: Sendable {
    public var name: String
    public var items: [ParsedItem]
    
    public init(name: String, items: [ParsedItem] = []) {
        self.name = name
        self.items = items
    }
}

public struct ParsedItem: Sendable {
    public var name: String
    public var options: [(detail: String, price: String)]
    
    public init(name: String, options: [(detail: String, price: String)] = []) {
        self.name = name
        self.options = options
    }
}

public struct SemanticHierarchyParser: Sendable {
    
    private static let recognizedBullets = [
        "-", "–", "—", "*", "+", "•", "·", "✦", "✧", "▪", "▪︎", "▫", "▫︎",
        "◆", "◇", "●", "○", "▸", "►", "→", "➤", "➔", "✓", "✔", "☑", "✅", "⚡"
    ]
    
    /// Intelligently parses raw, unformatted text into a structured document hierarchy
    public static func parse(rawText: String) -> ParsedDocument {
        let lines = rawText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard !lines.isEmpty else { return ParsedDocument() }
        
        var doc = ParsedDocument()
        var currentCategory: ParsedCategory?
        var currentDepartment: ParsedDepartment?
        var currentItem: ParsedItem?
        
        var startIndex = 0
        
        // 1. Detect Master Document Title from line 0/1 if prominent
        let firstLine = cleanMarkdown(lines[0])
        if lines.count > 1 && (lines[0].hasPrefix("# ") || (firstLine.count <= 32 && isLikelyTitle(firstLine))) {
            doc.title = firstLine
            startIndex = 1
        } else {
            doc.title = "MASTER CATALOG"
        }
        
        for i in startIndex..<lines.count {
            let line = lines[i]
            let clean = cleanMarkdown(line)
            
            // Check Level 0: Operational / CTA line (e.g. "DM @admin", "PAYMENT: CASH")
            if isOperationalOrCTA(clean) {
                if var item = currentItem {
                    currentDepartment?.items.append(item)
                    currentItem = nil
                }
                doc.operationalNotes.append(clean)
                continue
            }
            
            // Check Level 1: Category Header (e.g. "## Category", "1. Category", or all-caps short line)
            if isCategoryHeader(line) {
                if var item = currentItem {
                    currentDepartment?.items.append(item)
                    currentItem = nil
                }
                if let dept = currentDepartment {
                    currentCategory?.departments.append(dept)
                    currentDepartment = nil
                }
                if let cat = currentCategory {
                    doc.categories.append(cat)
                }
                currentCategory = ParsedCategory(name: stripLeadingNumbering(clean))
                continue
            }
            
            // Check Level 2: Department / Subheading Header (e.g. "### Dept", "1.1 Dept")
            if isDepartmentHeader(line) {
                if var item = currentItem {
                    currentDepartment?.items.append(item)
                    currentItem = nil
                }
                if let dept = currentDepartment {
                    currentCategory?.departments.append(dept)
                }
                let cleanDept = stripLeadingNumbering(clean)
                currentDepartment = ParsedDepartment(name: cleanDept)
                currentItem = ParsedItem(name: cleanDept)
                continue
            }
            
            // Check Level 4: Price / Detail Line (contains $, €, £, or dash with price)
            if isPriceOrDetailLine(line) {
                let parsed = parseDetailAndPrice(line)
                if currentItem == nil {
                    let defaultName = currentDepartment?.name ?? "ITEM"
                    currentItem = ParsedItem(name: defaultName)
                }
                currentItem?.options.append(parsed)
                continue
            }
            
            // Otherwise Level 3: Item Name
            if var item = currentItem {
                if currentDepartment == nil {
                    currentDepartment = ParsedDepartment(name: "ITEMS")
                }
                currentDepartment?.items.append(item)
            }
            currentItem = ParsedItem(name: stripLeadingNumbering(cleanBullet(clean)))
        }
        
        // Flush remaining buffers
        if let item = currentItem {
            if currentDepartment == nil {
                currentDepartment = ParsedDepartment(name: "ITEMS")
            }
            currentDepartment?.items.append(item)
        }
        if let dept = currentDepartment {
            if currentCategory == nil {
                currentCategory = ParsedCategory(name: "GENERAL")
            }
            currentCategory?.departments.append(dept)
        }
        if let cat = currentCategory {
            doc.categories.append(cat)
        }
        
        return doc
    }
    
    // MARK: - Classification Heuristics
    
    private static func isCategoryHeader(_ line: String) -> Bool {
        if line.hasPrefix("# ") || line.hasPrefix("## ") { return true }
        
        // Match "1. Title" or "1) Title" but NOT "1.1 Title"
        if let first = line.first, first.isNumber && line.count < 45 && !containsPrice(line) {
            let tokens = line.components(separatedBy: .whitespaces)
            if let firstToken = tokens.first {
                let cleanToken = firstToken.trimmingCharacters(in: CharacterSet(charactersIn: ".)"))
                if Int(cleanToken) != nil, !firstToken.contains(".") || firstToken.filter({ $0 == "." }).count == 1 && !firstToken.dropLast().contains(".") {
                    if !firstToken.contains(".") || firstToken.hasSuffix(".") {
                        return true
                    }
                }
            }
        }
        
        // Short ALL CAPS line with zero verbs
        let clean = cleanMarkdown(line)
        if clean.count <= 26 && clean == clean.uppercased() && clean.contains(where: { $0.isLetter }) && !containsPrice(line) {
            let verbs = countVerbs(in: clean)
            if verbs == 0 {
                return true
            }
        }
        
        return false
    }
    
    private static func isDepartmentHeader(_ line: String) -> Bool {
        if line.hasPrefix("### ") || line.hasPrefix("#### ") { return true }
        // Match "1.1 Oils & Vinegars", "A. Oils", etc.
        let tokens = line.components(separatedBy: .whitespaces)
        if let firstToken = tokens.first {
            if firstToken.contains(".") {
                let parts = firstToken.split(separator: ".")
                if parts.count >= 2 && parts.allSatisfy({ Int($0) != nil }) {
                    return true
                }
            }
        }
        return false
    }
    
    private static func isPriceOrDetailLine(_ line: String) -> Bool {
        return containsPrice(line) ||
               line.hasPrefix("- ") || line.hasPrefix("• ") || line.hasPrefix("➔") ||
               line.contains("mL") || line.contains("kg") || line.contains("g ") ||
               line.contains("oz") || line.contains("lb") || line.contains("Tin") ||
               line.contains("Drum") || line.contains("Sack") || line.contains("Bag")
    }
    
    private static func isOperationalOrCTA(_ line: String) -> Bool {
        let upper = line.uppercased()
        return upper.hasPrefix("RESERVE:") || upper.hasPrefix("PAYMENT:") ||
               upper.hasPrefix("DISPATCH:") || upper.hasPrefix("STATUS:") ||
               upper.hasPrefix("RSVP:") || upper.hasPrefix("HOURS:") ||
               upper.contains("DM @") || upper.contains("MINIMUM ORDER") ||
               upper.contains("ALL RIGHTS RESERVED")
    }
    
    private static func isLikelyTitle(_ line: String) -> Bool {
        let verbs = countVerbs(in: line)
        return verbs == 0 && !containsPrice(line)
    }
    
    private static func containsPrice(_ line: String) -> Bool {
        let currencySymbols = ["$", "€", "£", "¥", "₹", "₩", "₪", "USDC", "USD", "AUD", "CAD", "EUR", "GBP"]
        return currencySymbols.contains(where: { line.contains($0) })
    }
    
    // MARK: - Price & Detail Extraction
    
    private static func parseDetailAndPrice(_ line: String) -> (detail: String, price: String) {
        var clean = cleanMarkdown(line)
        for bullet in recognizedBullets {
            if clean.hasPrefix(bullet) {
                clean.removeFirst(bullet.count)
                clean = clean.trimmingCharacters(in: .whitespaces)
            }
        }
        clean = clean.trimmingCharacters(in: .whitespaces)
        
        // Priority 1: Currency sign with optional range or unit breakdown:
        // Matches $102.00 [$8.50/u] or €44.00 or $148 - $151
        let currencyRegex = #"([\$€£¥₹₩₪]|USDC\s*)[0-9]+(\.[0-9]{2})?(\s*-\s*[\$€£¥₹₩₪]?[0-9]+(\.[0-9]{2})?)?(\s*\[[^\]]+\]|\s*\([^\)]+\))?"#
        if let priceRange = clean.range(of: currencyRegex, options: .regularExpression) {
            let price = String(clean[priceRange])
            var detail = clean.replacingCharacters(in: priceRange, with: "")
            detail = detail.replacingOccurrences(of: " - ", with: " ")
            detail = detail.replacingOccurrences(of: " : ", with: " ")
            detail = detail.replacingOccurrences(of: ":", with: "")
            detail = detail.trimmingCharacters(in: CharacterSet(charactersIn: " -:\t"))
            return (detail.isEmpty ? "Standard" : detail, price)
        }
        
        // Priority 2: Price at the end of line like "- 28.00"
        if let priceRange = clean.range(of: #"[0-9]+(\.[0-9]{2})?$"#, options: .regularExpression) {
            let priceNum = String(clean[priceRange])
            var detail = clean.replacingCharacters(in: priceRange, with: "")
            detail = detail.trimmingCharacters(in: CharacterSet(charactersIn: " -:\t$€£¥"))
            return (detail.isEmpty ? "Standard" : detail, "$\(priceNum)")
        }
        
        return (clean, "")
    }
    
    // MARK: - NaturalLanguage Helpers
    
    private static func countVerbs(in text: String) -> Int {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        var count = 0
        let range = text.startIndex..<text.endIndex
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: [.omitWhitespace, .omitPunctuation]) { tag, _ in
            if tag == .verb {
                count += 1
            }
            return true
        }
        return count
    }
    
    private static func cleanBullet(_ text: String) -> String {
        var str = text
        for bullet in recognizedBullets {
            if str.hasPrefix(bullet) {
                str.removeFirst(bullet.count)
                str = str.trimmingCharacters(in: .whitespaces)
            }
        }
        return str
    }
    
    private static func cleanMarkdown(_ text: String) -> String {
        var str = text
        while str.hasPrefix("#") {
            str.removeFirst()
        }
        return str.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespaces)
    }
    
    private static func stripLeadingNumbering(_ text: String) -> String {
        var str = text.trimmingCharacters(in: .whitespaces)
        while str.hasPrefix("#") {
            str.removeFirst()
        }
        str = str.trimmingCharacters(in: .whitespaces)
        let pattern = #"^([0-9]+(\.[0-9]+)*|[A-Za-z])[.)]?\s+"#
        if let range = str.range(of: pattern, options: .regularExpression) {
            str.removeSubrange(range)
        }
        return str.trimmingCharacters(in: .whitespaces)
    }
}
