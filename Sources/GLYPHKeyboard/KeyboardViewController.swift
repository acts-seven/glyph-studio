import UIKit
import GLYPHCore

public class KeyboardViewController: UIInputViewController {
    
    private var activeStyle: TypographyStyle = .frakturBold
    private var activeTheme: ArchitecturalTheme = .obeliskGothic
    private var presetIndex: Int = 0
    private var isShifted: Bool = false
    private var letterButtons: [UIButton] = []
    
    // Tactile Feedback Engines
    private let feedbackLight = UIImpactFeedbackGenerator(style: .light)
    private let feedbackMedium = UIImpactFeedbackGenerator(style: .medium)
    private let feedbackNotification = UINotificationFeedbackGenerator()
    
    private let presetBtn = UIButton(type: .system)
    private let themeBtn = UIButton(type: .system)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        feedbackLight.prepare()
        feedbackMedium.prepare()
        feedbackNotification.prepare()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 1.0)
        
        let rootStack = UIStackView()
        rootStack.axis = .vertical
        rootStack.spacing = 5
        rootStack.distribution = .fillProportionally
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootStack)
        
        // MARK: - Row 1: Action Bar (Architect + Themes + Presets + Styles)
        let topScroll = UIScrollView()
        topScroll.showsHorizontalScrollIndicator = false
        topScroll.translatesAutoresizingMaskIntoConstraints = false
        
        let topBar = UIStackView()
        topBar.axis = .horizontal
        topBar.spacing = 6
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topScroll.addSubview(topBar)
        
        // 1. ✨ Architect Paste Button
        let architectBtn = UIButton(type: .system)
        architectBtn.setTitle("✨ Auto-Architect", for: .normal)
        architectBtn.setTitleColor(.white, for: .normal)
        architectBtn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        architectBtn.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.4, alpha: 1.0)
        architectBtn.layer.cornerRadius = 6
        architectBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        architectBtn.addAction(UIAction { [weak self] _ in
            self?.feedbackNotification.notificationOccurred(.success)
            self?.autoArchitectClipboard()
        }, for: .touchUpInside)
        topBar.addArrangedSubview(architectBtn)
        
        // 2. 🏛️ Architectural Theme Cycle Button
        updateThemeButtonLabel()
        themeBtn.setTitleColor(.white, for: .normal)
        themeBtn.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        themeBtn.backgroundColor = UIColor(red: 0.35, green: 0.25, blue: 0.65, alpha: 1.0)
        themeBtn.layer.cornerRadius = 6
        themeBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        themeBtn.addAction(UIAction { [weak self] _ in
            self?.cycleTheme()
        }, for: .touchUpInside)
        topBar.addArrangedSubview(themeBtn)
        
        // 3. Preset Cycle Button
        updatePresetButtonLabel()
        presetBtn.setTitleColor(.white, for: .normal)
        presetBtn.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        presetBtn.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0)
        presetBtn.layer.cornerRadius = 6
        presetBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        presetBtn.addAction(UIAction { [weak self] _ in
            self?.insertAndCyclePreset()
        }, for: .touchUpInside)
        topBar.addArrangedSubview(presetBtn)
        
        // 4. Style Buttons
        let styles: [(String, TypographyStyle)] = [
            ("𝕲𝖔𝖙𝖍𝖎𝖈", .frakturBold),
            ("𝓒𝓾𝓻𝓼𝓲𝓿𝓮", .cursiveBold),
            ("𝔻𝕠𝕦𝕓𝕝𝕖", .doubleStruck),
            ("𝗦𝗮𝗻𝘀", .sansBold),
            ("𝙼𝚘𝚗𝚘", .monospace)
        ]
        
        for (label, style) in styles {
            let btn = UIButton(type: .system)
            btn.setTitle(label, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            btn.backgroundColor = (self.activeStyle == style) ? UIColor(white: 0.35, alpha: 1.0) : UIColor(white: 0.18, alpha: 1.0)
            btn.layer.cornerRadius = 6
            btn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
            btn.addAction(UIAction { [weak self] _ in
                self?.feedbackLight.impactOccurred()
                self?.activeStyle = style
                self?.updateKeyLabels()
            }, for: .touchUpInside)
            topBar.addArrangedSubview(btn)
        }
        
        rootStack.addArrangedSubview(topScroll)
        
        // MARK: - Row 2: Quick Symbols Bar
        let symbolsScroll = UIScrollView()
        symbolsScroll.showsHorizontalScrollIndicator = false
        symbolsScroll.translatesAutoresizingMaskIntoConstraints = false
        
        let symbolsRow = UIStackView()
        symbolsRow.axis = .horizontal
        symbolsRow.spacing = 6
        symbolsRow.translatesAutoresizingMaskIntoConstraints = false
        symbolsScroll.addSubview(symbolsRow)
        
        let quickGlyphs = [
            "𓆩 ⚡︎ 𓆪", "𓆩 𖤍 𓆪", "░▒▓█", "╍╍ ❖ ╍╍", "༺ ༓ ༻",
            "⏣ ⎔ ⏣", "◈", "➔", "᚛ ᚜", "✦", "┠", "┃"
        ]
        for glyph in quickGlyphs {
            let btn = UIButton(type: .system)
            btn.setTitle(glyph, for: .normal)
            btn.setTitleColor(UIColor(red: 0.4, green: 0.75, blue: 1.0, alpha: 1.0), for: .normal)
            btn.titleLabel?.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
            btn.backgroundColor = UIColor(white: 0.14, alpha: 1.0)
            btn.layer.cornerRadius = 5
            btn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
            btn.addAction(UIAction { [weak self] _ in
                self?.feedbackLight.impactOccurred()
                self?.textDocumentProxy.insertText(glyph + " ")
            }, for: .touchUpInside)
            symbolsRow.addArrangedSubview(btn)
        }
        rootStack.addArrangedSubview(symbolsScroll)
        
        // MARK: - QWERTY Keyboard Rows
        let row1Keys = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        let row2Keys = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        let row3Keys = ["Z", "X", "C", "V", "B", "N", "M"]
        
        rootStack.addArrangedSubview(makeKeyRow(keys: row1Keys))
        rootStack.addArrangedSubview(makeKeyRow(keys: row2Keys, horizontalInset: 15))
        
        // Row 3 with Shift and Delete
        let row3Stack = UIStackView()
        row3Stack.axis = .horizontal
        row3Stack.spacing = 5
        row3Stack.distribution = .fillProportionally
        
        let shiftBtn = UIButton(type: .system)
        shiftBtn.setTitle("⇧", for: .normal)
        shiftBtn.setTitleColor(.white, for: .normal)
        shiftBtn.backgroundColor = UIColor(white: 0.22, alpha: 1.0)
        shiftBtn.layer.cornerRadius = 5
        shiftBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        shiftBtn.addAction(UIAction { [weak self] _ in
            self?.feedbackLight.impactOccurred()
            self?.isShifted.toggle()
            self?.updateKeyLabels()
        }, for: .touchUpInside)
        row3Stack.addArrangedSubview(shiftBtn)
        
        for key in row3Keys {
            let keyBtn = makeKeyButton(key: key)
            letterButtons.append(keyBtn)
            row3Stack.addArrangedSubview(keyBtn)
        }
        
        let deleteBtn = UIButton(type: .system)
        deleteBtn.setTitle("⌫", for: .normal)
        deleteBtn.setTitleColor(.white, for: .normal)
        deleteBtn.backgroundColor = UIColor(white: 0.22, alpha: 1.0)
        deleteBtn.layer.cornerRadius = 5
        deleteBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        deleteBtn.addAction(UIAction { [weak self] _ in
            self?.feedbackMedium.impactOccurred()
            self?.textDocumentProxy.deleteBackward()
        }, for: .touchUpInside)
        row3Stack.addArrangedSubview(deleteBtn)
        
        rootStack.addArrangedSubview(row3Stack)
        
        // MARK: - Bottom Row: Next Keyboard, Space, Return
        let bottomStack = UIStackView()
        bottomStack.axis = .horizontal
        bottomStack.spacing = 6
        bottomStack.distribution = .fillProportionally
        
        let globeBtn = UIButton(type: .system)
        globeBtn.setTitle("🌐", for: .normal)
        globeBtn.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        globeBtn.layer.cornerRadius = 5
        globeBtn.widthAnchor.constraint(equalToConstant: 42).isActive = true
        globeBtn.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        bottomStack.addArrangedSubview(globeBtn)
        
        let spaceBtn = UIButton(type: .system)
        spaceBtn.setTitle("space", for: .normal)
        spaceBtn.setTitleColor(.white, for: .normal)
        spaceBtn.backgroundColor = UIColor(white: 0.28, alpha: 1.0)
        spaceBtn.layer.cornerRadius = 5
        spaceBtn.addAction(UIAction { [weak self] _ in
            self?.feedbackLight.impactOccurred()
            self?.textDocumentProxy.insertText(" ")
        }, for: .touchUpInside)
        bottomStack.addArrangedSubview(spaceBtn)
        
        let returnBtn = UIButton(type: .system)
        returnBtn.setTitle("return", for: .normal)
        returnBtn.setTitleColor(.white, for: .normal)
        returnBtn.backgroundColor = UIColor(red: 0.15, green: 0.45, blue: 0.85, alpha: 1.0)
        returnBtn.layer.cornerRadius = 5
        returnBtn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        returnBtn.addAction(UIAction { [weak self] _ in
            self?.feedbackLight.impactOccurred()
            self?.textDocumentProxy.insertText("\n")
        }, for: .touchUpInside)
        bottomStack.addArrangedSubview(returnBtn)
        
        rootStack.addArrangedSubview(bottomStack)
        
        // MARK: - AutoLayout Constraints
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6),
            
            topBar.topAnchor.constraint(equalTo: topScroll.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: topScroll.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: topScroll.trailingAnchor),
            topBar.bottomAnchor.constraint(equalTo: topScroll.bottomAnchor),
            topBar.heightAnchor.constraint(equalTo: topScroll.heightAnchor),
            topScroll.heightAnchor.constraint(equalToConstant: 32),
            
            symbolsRow.topAnchor.constraint(equalTo: symbolsScroll.topAnchor),
            symbolsRow.leadingAnchor.constraint(equalTo: symbolsScroll.leadingAnchor),
            symbolsRow.trailingAnchor.constraint(equalTo: symbolsScroll.trailingAnchor),
            symbolsRow.bottomAnchor.constraint(equalTo: symbolsScroll.bottomAnchor),
            symbolsRow.heightAnchor.constraint(equalTo: symbolsScroll.heightAnchor),
            symbolsScroll.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func makeKeyRow(keys: [String], horizontalInset: CGFloat = 0) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 5
        rowStack.distribution = .fillEqually
        
        for key in keys {
            let btn = makeKeyButton(key: key)
            letterButtons.append(btn)
            rowStack.addArrangedSubview(btn)
        }
        return rowStack
    }
    
    private func makeKeyButton(key: String) -> UIButton {
        let btn = UIButton(type: .system)
        let displayKey = isShifted ? key.uppercased() : key.lowercased()
        let converted = UnicodeFontConverter.shared.convert(displayKey, to: activeStyle)
        btn.setTitle(converted, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.backgroundColor = UIColor(white: 0.28, alpha: 1.0)
        btn.layer.cornerRadius = 5
        btn.accessibilityLabel = key
        
        btn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.feedbackLight.impactOccurred()
            let charToInsert = self.isShifted ? key.uppercased() : key.lowercased()
            let transcoded = UnicodeFontConverter.shared.convert(charToInsert, to: self.activeStyle)
            self.textDocumentProxy.insertText(transcoded)
        }, for: .touchUpInside)
        
        return btn
    }
    
    private func updateKeyLabels() {
        for btn in letterButtons {
            guard let key = btn.accessibilityLabel else { continue }
            let char = isShifted ? key.uppercased() : key.lowercased()
            let converted = UnicodeFontConverter.shared.convert(char, to: activeStyle)
            btn.setTitle(converted, for: .normal)
        }
    }
    
    private func cycleTheme() {
        feedbackLight.impactOccurred()
        let allThemes = ArchitecturalTheme.allCases
        if let idx = allThemes.firstIndex(of: activeTheme) {
            activeTheme = allThemes[(idx + 1) % allThemes.count]
        } else {
            activeTheme = .obeliskGothic
        }
        updateThemeButtonLabel()
    }
    
    private func updateThemeButtonLabel() {
        let name = activeTheme.rawValue.components(separatedBy: " ").first ?? "Apex"
        themeBtn.setTitle("🏛️ \(name)", for: .normal)
    }
    
    private func insertAndCyclePreset() {
        feedbackLight.impactOccurred()
        let presets = PresetsLibrary.allPresets
        guard !presets.isEmpty else { return }
        let currentPreset = presets[presetIndex % presets.count]
        textDocumentProxy.insertText(currentPreset.rawContent)
        presetIndex = (presetIndex + 1) % presets.count
        updatePresetButtonLabel()
    }
    
    private func updatePresetButtonLabel() {
        let presets = PresetsLibrary.allPresets
        guard !presets.isEmpty else {
            presetBtn.setTitle("📋 Presets", for: .normal)
            return
        }
        let nextPreset = presets[presetIndex % presets.count]
        let shortTitle = String(nextPreset.title.prefix(8))
        presetBtn.setTitle("📋 \(shortTitle)…", for: .normal)
    }
    
    private func autoArchitectClipboard() {
        guard let clipboard = UIPasteboard.general.string, !clipboard.isEmpty else { return }
        let parsed = SemanticHierarchyParser.parse(rawText: clipboard)
        let formatted = HierarchicalThemeFormatter.format(
            document: parsed,
            theme: activeTheme,
            fontStyle: activeStyle
        )
        textDocumentProxy.insertText(formatted)
    }
}
