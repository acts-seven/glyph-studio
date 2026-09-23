# Compounding Knowledge Vault: GLYPH Signal Studio

This document records architectural principles, theoretical root causes, platform idiosyncrasies, and regression defense rules uncovered during recursive craftsmanship iterations under the `perpetual-craft-innovator` loop.

---

## 1. Unicode Variation Selector Precedence (TR51)
* **Discovery Date**: 2026-09-23
* **Context**: `WrapToleranceSensor.swift` / `TextWidthMetrics.visualColumnWidth`
* **Defect**: Characters like `⚡︎` (`U+26A1` + `U+FE0E`) and `⚔︎` (`U+2694` + `U+FE0E`) were evaluated as 2 visual columns instead of 1.
* **Root Cause**: `U+26A1` has `isEmojiPresentation == true` in Swift Unicode properties. Because `char.unicodeScalars.contains(where: { $0.properties.isEmojiPresentation })` was evaluated before inspecting `U+FE0E` (Variation Selector 15), the emoji check matched first, discarding the explicit text presentation override.
* **Theoretical Grounding**: Under Unicode Technical Report #51 (Unicode Emoji), an explicit Variation Selector 15 (`U+FE0E`) forces text presentation (monochrome glyph with single column width = 1), whereas Variation Selector 16 (`U+FE0F`) forces emoji presentation (width = 2).
* **Prevention Rule**: Always evaluate `U+FE0E` *before* `isEmojiPresentation` in visual column width calculations.

---

## 2. Geometric Frame Invariant Defense in Procedural Monoliths
* **Discovery Date**: 2026-09-23
* **Context**: `ProceduralMonolithGenerator.swift`
* **Defect**: When users input long titles or body lines, procedural monolith cards blew out from 22 columns to 40+ columns, destroying the rectangular ASCII box frame and overflowing mobile chat bubbles.
* **Root Cause**: `centerText` returned the raw untruncated string whenever `visualLen >= width`. Furthermore, body lines and galactic crown/swirl elements lacked strict bounding.
* **Architectural Solution**:
  1. Title monolith interior is bounded with `HierarchicalThemeFormatter.fitText(styledTitle, maxVisualWidth: 18)` before centering in the 22-column box `╭━━━...━━━╮`.
  2. Procedural body lines are bounded to 19 visual columns max: `"◈ " + fitText(line, maxVisualWidth: 19)` ($\le 21$ columns).
  3. Galactic crown and swirl strings adjusted to 22 and 23 columns respectively, guaranteeing that every line in all 6 vibes strictly satisfies $\le 24$ columns.
* **Automated Regression Guard**: `GLYPHCoreTests.testProceduralMonolithBoxGeometryWithLongTitle` fuzzes 60-character titles across all vibes and asserts that top, middle, and bottom lines of the box are exactly 22 columns wide.

---

## 3. Subheading (H3/H4) vs. Category (H2) Parsing Priority
* **Discovery Date**: 2026-09-23
* **Context**: `SemanticHierarchyParser.swift`
* **Defect**: Subheading lines like `### 1.1 WAGYU A5 RIB CAP` were falsely classified as Category headers instead of Department headers, creating spurious categories.
* **Root Cause**: `cleanMarkdown` stripped the `###` hashes into `"1.1 WAGYU A5 RIB CAP"`. The all-caps zero-verb category fallback rule matched the line *before* `isDepartmentHeader` was ever evaluated in the sequential parsing loop.
* **Architectural Solution**:
  1. Evaluated `isDepartmentHeader` *before* `isCategoryHeader` in the main parse loop.
  2. Hardened `isCategoryHeader` to explicitly reject any line with `###` or `####` prefixes or multi-part decimal numbering (`1.1`, `2.3`).
* **Automated Regression Guard**: `GLYPHCoreTests.testSemanticHierarchyParser` verifies that nested H2/H3 hierarchies parse into exactly 1 category with correct departmental children.

---

## 4. Modern iOS Viewport Dimensions & Custom Keyboard Haptics
* **Discovery Date**: 2026-09-23
* **Context**: `SignalMirrorPane.swift` & `KeyboardViewController.swift`
* **Defect**:
  - `SignalMirrorPane` specified iPhone SE at `320pt` (the 2012 iPhone 5 form factor) rather than the modern `375pt` (iPhone SE 2nd/3rd gen).
  - Keyboard extension lacked tactile feedback and hardcoded theme formatting to `.obeliskGothic`.
* **Architectural Solution**:
  1. Updated viewport selector: `SE (375pt)`, `16 Pro (393pt)`, `16 Pro Max (440pt)`.
  2. Integrated low-latency `UIImpactFeedbackGenerator(style: .light)` and `UINotificationFeedbackGenerator()` across key taps, shifts, deletes, presets, and architect actions.
  3. Added dynamic theme cycling (`🏛️ [Theme]`) and preset rotation directly in the iOS custom keyboard top action bar.
  4. Added dual-mode preview toggle (Proportional Signal Default vs Monospace Sandbox) in the macOS conversation bar.
