import SwiftUI
import GLYPHCore

public struct SignalMirrorPane: View {
    @Bindable var state: AppState
    
    public var body: some View {
        VStack(spacing: 0) {
            // Simulated Signal Conversation Bar
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(hex: "#2C6BED"))
                    .frame(width: 32, height: 32)
                    .overlay(Text("⚡︎").foregroundColor(.white).font(.system(size: 14, weight: .bold)))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Signal Alpha Channel")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(state.isDarkMode ? .white : .black)
                    Text("Verified End-to-End Encrypted")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Monospace / Proportional Font Toggle
                Button(action: { state.isMonospacePreview.toggle() }) {
                    Image(systemName: state.isMonospacePreview ? "character.textbox" : "textformat")
                        .foregroundColor(state.isMonospacePreview ? Color(hex: "#2C6BED") : .gray)
                }
                .buttonStyle(.plain)
                .help(state.isMonospacePreview ? "Switch to Proportional (Signal Default)" : "Switch to Monospace Preview")
                
                // Dark/Light Mode Toggle
                Button(action: { state.isDarkMode.toggle() }) {
                    Image(systemName: state.isDarkMode ? "moon.fill" : "sun.max.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(state.isDarkMode ? Color(hex: "#18181A") : Color.white)
            
            Divider()
            
            // Scrollable Chat Canvas
            ScrollView {
                VStack(alignment: .trailing, spacing: 12) {
                    Spacer(minLength: 20)
                    
                    // The Outgoing Mirrored Signal Bubble
                    HStack {
                        Spacer(minLength: 30)
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(state.currentText.isEmpty ? "Preview appears here..." : state.currentText)
                                .font(.system(size: 15, weight: .regular, design: state.isMonospacePreview ? .monospaced : .default))
                                .foregroundColor(state.currentText.isEmpty ? .gray : .white)
                                .lineSpacing(3)
                                .padding(.horizontal, 12)
                                .padding(.top, 8)
                                .padding(.bottom, 2)
                            
                            // Signal Metadata Floor (Time + Double Checkmarks)
                            HStack(spacing: 3) {
                                Text("21:30")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.6))
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(Color(hex: "#2C6BED"))
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(Color(hex: "#2C6BED"))
                                    .offset(x: -4)
                            }
                            .padding(.trailing, 10)
                            .padding(.bottom, 6)
                        }
                        .frame(maxWidth: state.simulatedWidth * 0.74, alignment: .leading)
                        .background(Color(hex: "#2C2C2E"))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
                .padding()
            }
            .background(state.isDarkMode ? Color(hex: "#121212") : Color(hex: "#F2F2F7"))
            
            Divider()
            
            // Bottom Action & Device Sizer Bar
            HStack {
                Button(action: { state.copyToClipboard() }) {
                    HStack(spacing: 6) {
                        Image(systemName: state.showCopiedBanner ? "checkmark" : "doc.on.doc")
                        Text(state.showCopiedBanner ? "Copied to Clipboard!" : "Copy for Signal (⌘⇧C)")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#2C6BED"))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .keyboardShortcut("c", modifiers: [.command, .shift])
                
                Spacer()
                
                Picker("Screen Size", selection: $state.simulatedWidth) {
                    Text("SE (375pt)").tag(CGFloat(375))
                    Text("16 Pro (393pt)").tag(CGFloat(393))
                    Text("16 Pro Max (440pt)").tag(CGFloat(440))
                }
                .pickerStyle(.segmented)
                .frame(width: 270)
            }
            .padding(10)
            .background(state.isDarkMode ? Color(hex: "#18181A") : Color.white)
        }
    }
}
