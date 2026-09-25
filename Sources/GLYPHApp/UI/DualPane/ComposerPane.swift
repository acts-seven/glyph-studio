import SwiftUI
import GLYPHCore

public struct ComposerPane: View {
    @Bindable var state: AppState
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Toolbar Row 1: Core Action & Hierarchy Architecture
            HStack(spacing: 8) {
                // 1. Paste & Auto-Architect (One-Tap Clipboard Magic)
                Button(action: { state.pasteAndArchitect() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "doc.on.clipboard.fill")
                        Text("📋 Paste & Architect (⌘⇧V)")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#0A84FF"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .keyboardShortcut("v", modifiers: [.command, .shift])
                
                // 2. Auto-Architect Current Text
                Button(action: { state.autoArchitect() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "wand.and.stars")
                        Text("✨ Auto-Architect (⌘↩)")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#8A2387"), Color(hex: "#E94057"), Color(hex: "#F27121")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: Color.orange.opacity(0.3), radius: 3, x: 0, y: 1)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.return, modifiers: [.command])
                
                // 3. Theme Selector
                Picker("Theme", selection: $state.selectedTheme) {
                    ForEach(ArchitecturalTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .frame(width: 140)
                
                // 4. Wrap Lines Button (On-Demand Safe Word Wrap)
                Button(action: { state.wrapCurrentTextToSafeWidth() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.turn.down.left")
                        Text("Wrap Lines (≤24)")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "#7EE787"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(hex: "#238636").opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(hex: "#238636").opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .help("Intelligently wrap any lines exceeding 24 columns across word boundaries with tree indentation")
                
                Spacer()
                
                // 5. Wrap Safety Status Badge (Click to auto-wrap hazards)
                Button(action: {
                    if state.dangerCount > 0 {
                        state.wrapCurrentTextToSafeWidth()
                    }
                }) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(state.dangerCount == 0 ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(state.dangerCount == 0 ? "Wrap Safe (≤24 col)" : "\(state.dangerCount) Hazards (Click to Fix)")
                            .font(.caption2.bold())
                            .foregroundColor(state.dangerCount == 0 ? .green : .red)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .help(state.dangerCount == 0 ? "All lines strictly fit Signal's 24-column bubble width" : "Click to automatically wrap all hazard lines")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(hex: "#161B22"))
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // MARK: - Toolbar Row 2: Typography & Generative Presets
            HStack(spacing: 8) {
                // Typography Font Style Picker
                Picker("Font", selection: $state.activeStyle) {
                    ForEach(TypographyStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .frame(width: 130)
                
                // Transcode Text to Font
                Button(action: { state.transcodeAllText(to: state.activeStyle) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "character")
                        Text("Transcode Font (⌘T)")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#58A6FF"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(hex: "#58A6FF").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .keyboardShortcut("t", modifiers: [.command])
                
                // Ready-to-Copy Presets Menu
                Menu {
                    ForEach(PresetsLibrary.allPresets) { preset in
                        Button("\(preset.category): \(preset.title)") {
                            state.applyPreset(preset)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "text.badge.star")
                        Text("Presets (\(PresetsLibrary.allPresets.count))")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#E5C07B"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(hex: "#E5C07B").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                // Generative Procedural Roll Menu
                Menu {
                    ForEach(ProceduralVibe.allCases) { vibe in
                        Button(vibe.rawValue) {
                            state.applyProceduralRoll(vibe: vibe)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "dice")
                        Text("Procedural Roll")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#C678DD"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(hex: "#C678DD").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                Spacer()
                
                // Clear Editor Button
                Button(action: { state.currentText = "" }) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .padding(5)
                }
                .buttonStyle(.plain)
                .help("Clear editor")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "#1A202C"))
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // MARK: - Center Editor (The Monospace Conduit)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(hex: "#0D1117"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(hex: "#30363D"), lineWidth: 1)
                    )
                
                TextEditor(text: $state.currentText)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(hex: "#E6EDF3"))
                    .scrollContentBackground(.hidden)
                    .padding(10)
                
                if state.currentText.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "#8A2387"), Color(hex: "#E94057"), Color(hex: "#F27121")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("The Monospace Conduit")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Type raw text, paste unstructured goods, or tap a preset to architect for Signal mobile viewports.")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        HStack(spacing: 10) {
                            Button(action: { state.pasteAndArchitect() }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "doc.on.clipboard.fill")
                                    Text("Paste & Architect (⌘⇧V)")
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color(hex: "#0A84FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                if let sample = PresetsLibrary.allPresets.first {
                                    state.applyPreset(sample)
                                }
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "tray.and.arrow.down.fill")
                                    Text("Load Sample Catalog")
                                }
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(hex: "#E5C07B"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color(hex: "#E5C07B").opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 4)
                        
                        Text("⌘↩ Architect  •  ⌘⇧V Paste  •  ⌘⇧C Copy  •  ⌘T Transcode")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.top, 8)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(10)
            
            // MARK: - Bottom Quick Glyph Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    let quickGlyphs = [
                        "𓆩 ⚡︎ 𓆪", "𓆩 𖤍 𓆪", "░▒▓█", "╍╍ ❖ ╍╍", "༺ ༓ ༻",
                        "⏣ ⎔ ⏣", "◈", "➔", "᚛ ᚜", "✦", "┠", "┃"
                    ]
                    ForEach(quickGlyphs, id: \.self) { glyph in
                        Button(action: { state.insertGlyph(glyph) }) {
                            Text(glyph)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color(hex: "#79C0FF"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
            .background(Color(hex: "#161B22"))
        }
        .background(Color(hex: "#0F141C"))
    }
}
