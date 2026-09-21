import Foundation

public struct ParsedDocument: Sendable {
    public var title: String
    public var categories: [ParsedCategory]
    
    public init(title: String = "", categories: [ParsedCategory] = []) {
        self.title = title
        self.categories = categories
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
        
        // 1. Detect Master Document Title from line 1 if prominent
        let firstLine = cleanMarkdown(lines[0])
        if lines.count > 1 && (lines[0].hasPrefix("# ") || lines[0].count < 35) {
            doc.title = firstLine
            startIndex = 1
        } else {
            doc.title = "MASTER CATALOG"
        }
        
        for i in startIndex..<lines.count {
            let line = lines[i]
            let clean = cleanMarkdown(line)
            
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
                currentCategory = ParsedCategory(name: clean)
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
                currentDepartment = ParsedDepartment(name: clean)
                continue
            }
            
            // Check Level 4: Price / Detail Line (contains $, €, £, or dash with price)
            if isPriceOrDetailLine(line) {
                let parsed = parseDetailAndPrice(line)
                if currentItem == nil {
                    currentItem = ParsedItem(name: "ITEM")
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
            currentItem = ParsedItem(name: clean)
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
    
    private static func isCategoryHeader(_ line: String) -> Bool {
        if line.hasPrefix("# ") || line.hasPrefix("## ") { return true }
        // Match "1. Title" or "1) Title" but NOT "1.1 Title"
        if let first = line.first, first.isNumber && line.count < 45 && !line.contains("$") {
            let tokens = line.components(separatedBy: .whitespaces)
            if let firstToken = tokens.first {
                let cleanToken = firstToken.trimmingCharacters(in: CharacterSet(charactersIn: ".)"))
                if let num = Int(cleanToken), !firstToken.contains(".") || firstToken.filter({ $0 == "." }).count == 1 && !firstToken.dropLast().contains(".") {
                    // It's a single level number like "1."
                    if !firstToken.contains(".") || firstToken.hasSuffix(".") {
                        return true
                    }
                }
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
        return line.contains("$") || line.contains("€") || line.contains("£") ||
               line.hasPrefix("- ") || line.hasPrefix("• ") || line.hasPrefix("➔") ||
               line.contains("mL") || line.contains("kg") || line.contains("g ")
    }
    
    private static func parseDetailAndPrice(_ line: String) -> (detail: String, price: String) {
        var clean = cleanMarkdown(line)
        clean = clean.replacingOccurrences(of: "• ", with: "")
        clean = clean.replacingOccurrences(of: "- ", with: "")
        clean = clean.replacingOccurrences(of: "➔", with: "")
        clean = clean.trimmingCharacters(in: .whitespaces)
        
        // Priority 1: Match explicit currency sign: $28.00 or $102
        if let priceRange = clean.range(of: #"[\$€£][0-9]+(\.[0-9]{2})?"#, options: .regularExpression) {
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
            detail = detail.trimmingCharacters(in: CharacterSet(charactersIn: " -:\t$€£"))
            return (detail.isEmpty ? "Standard" : detail, "$\(priceNum)")
        }
        
        return (clean, "")
    }
    
    private static func cleanMarkdown(_ text: String) -> String {
        var str = text
        while str.hasPrefix("#") {
            str.removeFirst()
        }
        return str.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespaces)
    }
}
