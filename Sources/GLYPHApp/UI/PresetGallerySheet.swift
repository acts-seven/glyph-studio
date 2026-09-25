import SwiftUI
import GLYPHCore

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct PresetGallerySheet: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategoryId: String = "All"
    @State private var searchQuery: String = ""
    @State private var selectedPresetId: String = PresetsLibrary.allPresets.first?.id ?? ""
    @State private var variableValues: [String: String] = [:]
    
    private var categories: [String] {
        ["All"] + PresetsLibrary.categories
    }
    
    private var filteredPresets: [SignalPostPreset] {
        var presets = PresetsLibrary.allPresets
        
        if selectedCategoryId != "All" {
            presets = presets.filter { $0.category == selectedCategoryId }
        }
        
        if !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchQuery.lowercased()
            presets = presets.filter { p in
                p.title.lowercased().contains(q) ||
                p.description.lowercased().contains(q) ||
                p.category.lowercased().contains(q) ||
                p.tags.contains(where: { $0.lowercased().contains(q) })
            }
        }
        
        return presets
    }
    
    private var selectedPreset: SignalPostPreset? {
        PresetsLibrary.preset(for: selectedPresetId) ?? filteredPresets.first
    }
    
    private var renderedOutput: String {
        guard let p = selectedPreset else { return "" }
        return p.render(with: variableValues, maxColumns: 24)
    }
    
    private var renderedMaxWidth: Int {
        let lines = renderedOutput.components(separatedBy: .newlines)
        return lines.map { TextWidthMetrics.visualColumnWidth(of: $0) }.max() ?? 0
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            headerBar
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // MARK: - Master Detail Content
            HStack(spacing: 0) {
                // Left Column: Category selector + Search + List
                presetListPane
                    .frame(width: 380)
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Right Column: Live Inspector, Parameter Form, and Preview
                presetInspectorPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // MARK: - Footer Actions
            footerBar
        }
        .frame(minWidth: 920, idealWidth: 1040, minHeight: 680, idealHeight: 740)
        .background(Color(hex: "#0D1117"))
        .onAppear {
            if let first = PresetsLibrary.allPresets.first {
                selectPreset(first)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerBar: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#F27121"), Color(hex: "#E94057"), Color(hex: "#8A2387")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("GLYPH Preset Vault")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(PresetsLibrary.allPresets.count) Presets")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "#58A6FF"))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "#58A6FF").opacity(0.15))
                        .clipShape(Capsule())
                }
                
                Text("Mobile-safe (≤24 columns) structural templates ready for Signal broadcasts & plugin automation")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#8B949E"))
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#8B949E"))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color(hex: "#161B22"))
    }
    
    private var presetListPane: some View {
        VStack(spacing: 0) {
            // Search Box
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "#8B949E"))
                    .font(.system(size: 12))
                
                TextField("Search presets, tags, or domains...", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                
                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: "#8B949E"))
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color(hex: "#0D1117"))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(10)
            
            // Category Filter Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(categories, id: \.self) { cat in
                        Button(action: { selectedCategoryId = cat }) {
                            Text(cat)
                                .font(.system(size: 11, weight: selectedCategoryId == cat ? .bold : .medium))
                                .foregroundColor(selectedCategoryId == cat ? .white : Color(hex: "#8B949E"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(selectedCategoryId == cat ? Color(hex: "#1F6FEB") : Color(hex: "#21262D"))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            }
            
            Divider()
                .background(Color.white.opacity(0.08))
            
            // Preset Cards List
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(filteredPresets) { preset in
                        presetCardRow(preset)
                    }
                }
                .padding(10)
            }
        }
        .background(Color(hex: "#161B22").opacity(0.6))
    }
    
    private func presetCardRow(_ preset: SignalPostPreset) -> some View {
        let isSelected = selectedPreset?.id == preset.id
        
        return Button(action: { selectPreset(preset) }) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .center) {
                    Text(preset.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isSelected ? .white : Color(hex: "#C9D1D9"))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if !preset.variables.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 9))
                            Text("\(preset.variables.count)")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(Color(hex: "#58A6FF"))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color(hex: "#58A6FF").opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
                
                Text(preset.description)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#8B949E"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 4) {
                    Text(preset.category)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#7EE787"))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color(hex: "#238636").opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    ForEach(preset.tags.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.system(size: 9))
                            .foregroundColor(Color(hex: "#8B949E"))
                    }
                }
            }
            .padding(10)
            .background(isSelected ? Color(hex: "#1F6FEB").opacity(0.2) : Color(hex: "#21262D").opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color(hex: "#58A6FF") : Color.white.opacity(0.06), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var presetInspectorPane: some View {
        Group {
            if let preset = selectedPreset {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Title & Metadata
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(preset.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // Width & Safety Badge
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(renderedMaxWidth <= 24 ? Color.green : Color.red)
                                        .frame(width: 7, height: 7)
                                    Text("\(renderedMaxWidth)/24 cols")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(renderedMaxWidth <= 24 ? .green : .red)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Capsule())
                            }
                            
                            Text(preset.description)
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#8B949E"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Variables Input Form (if preset has variables)
                        let varInfos = preset.variableInfos
                        if !varInfos.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Label("Template Parameters", systemImage: "slider.horizontal.3")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color(hex: "#58A6FF"))
                                    
                                    Spacer()
                                    
                                    Button("Reset Defaults") {
                                        resetDefaults(for: preset)
                                    }
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(hex: "#8B949E"))
                                    .buttonStyle(.plain)
                                }
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                    ForEach(varInfos) { info in
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(info.key)
                                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                                .foregroundColor(Color(hex: "#C9D1D9"))
                                            
                                            TextField(info.defaultValue ?? "", text: Binding(
                                                get: { variableValues[info.key] ?? info.defaultValue ?? "" },
                                                set: { variableValues[info.key] = $0 }
                                            ))
                                            .textFieldStyle(.plain)
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 5)
                                            .background(Color(hex: "#161B22"))
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color(hex: "#161B22").opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 16)
                        }
                        
                        // Live Chat Bubble Preview
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SIGNAL BUBBLE PREVIEW (≤24 COLUMNS)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "#8B949E"))
                            
                            // Bubble Container
                            VStack(alignment: .leading, spacing: 0) {
                                Text(renderedOutput)
                                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                                    .lineSpacing(2)
                                    .foregroundColor(.white)
                                    .textSelection(.enabled)
                                    .padding(14)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "#1A1D24"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#8B949E"))
                    Text("Select a preset from the catalog")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#8B949E"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private var footerBar: some View {
        HStack(spacing: 12) {
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.plain)
            .foregroundColor(Color(hex: "#8B949E"))
            .font(.system(size: 12))
            
            Spacer()
            
            Button(action: {
                copyRenderedToClipboard()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy Preset")
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color(hex: "#21262D"))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            
            Button(action: {
                if let p = selectedPreset {
                    state.applyRenderedPreset(renderedOutput, title: p.title)
                    dismiss()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Apply to Composer")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color(hex: "#238636"))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color(hex: "#161B22"))
    }
    
    // MARK: - Actions
    
    private func selectPreset(_ preset: SignalPostPreset) {
        selectedPresetId = preset.id
        resetDefaults(for: preset)
    }
    
    private func resetDefaults(for preset: SignalPostPreset) {
        variableValues = preset.defaultVariables
    }
    
    private func copyRenderedToClipboard() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(renderedOutput, forType: .string)
        #else
        UIPasteboard.general.string = renderedOutput
        #endif
        
        dismiss()
    }
}
