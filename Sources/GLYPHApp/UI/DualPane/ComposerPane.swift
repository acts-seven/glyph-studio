import SwiftUI
import GLYPHCore

public struct ComposerPane: View {
    @Bindable var state: AppState
    @State private var quickTextToAdd: String = ""
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Toolbar
            HStack {
                Picker("Active Font", selection: $state.activeStyle) {
                    ForEach(TypographyStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .frame(width: 160)
                
                Menu("🎲 Procedural Roll") {
                    ForEach(ProceduralVibe.allCases) { vibe in
                        Button(vibe.rawValue) {
                            state.applyProceduralRoll(vibe: vibe)
                        }
                    }
                }
                
                Button(action: { state.autoArchitect() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "wand.and.stars")
                        Text("✨ Auto-Architect")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#8A2387"), Color(hex: "#E94057"), Color(hex: "#F27121")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Wrap Safety Status Badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(state.dangerCount == 0 ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(state.dangerCount == 0 ? "Wrap Safe" : "\(state.dangerCount) Hazards")
                        .font(.caption2.bold())
                        .foregroundColor(state.dangerCount == 0 ? .green : .red)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.2))
                .clipShape(Capsule())
            }
            .padding(10)
            .background(Color(hex: "#1A202C"))
            
            Divider()
            
            // Text Editor Container (The Blue Bubble Container)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#0A84FF").opacity(0.12), Color(hex: "#0066CC").opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(hex: "#0A84FF").opacity(0.25), lineWidth: 1)
                    )
                
                TextEditor(text: $state.currentText)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(12)
            }
            .padding(12)
            
            // Quick Glyphs Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    let quickGlyphs = ["𓆩 ⚡︎ 𓆪", "𓆩 𖤍 𓆪", "░▒▓█", "╍╍ ❖ ╍╍", "༺ ༓ ༻", "⏣ ⎔ ⏣", "◈", "➔"]
                    ForEach(quickGlyphs, id: \.self) { glyph in
                        Button(action: { state.insertGlyph(glyph) }) {
                            Text(glyph)
                                .font(.system(size: 13, design: .monospaced))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
        }
        .background(Color(hex: "#12151C"))
    }
}
