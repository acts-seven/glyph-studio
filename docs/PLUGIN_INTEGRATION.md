# GLYPH Plugin Integration Guide for Signal Auto Poster

This guide details how **Signal Auto Poster** (`/Users/tb/Developer/apps/signal-auto-poster`) can seamlessly integrate **GLYPH** as an aesthetic layout, ASCII monolith, and mobile-safe broadcast preset plugin.

---

## Architecture Overview

GLYPH provides dual-mode integration:
1. **Mode A (In-Process SPM)**: Native Swift library linking via `import GLYPHCore`. Zero serialization overhead, compile-time type safety, synchronous or async execution.
2. **Mode B (Out-of-Process CLI / Subprocess)**: Autonomous background daemon communication using `glyph rpc` or one-shot `glyph plugin --json '...'`. Decoupled architecture matching Signal Auto Poster's existing `signal-cli` child process pattern.

```
┌────────────────────────────────────────────────────────┐
│                   Signal Auto Poster                   │
│         (MessageComposerView / BroadcastStore)         │
└───────────────┬────────────────────────┬───────────────┘
                │                        │
       (Option A: In-Process)   (Option B: Subprocess)
                │                        │
                ▼                        ▼
      ┌──────────────────┐     ┌──────────────────┐
      │  GLYPHCore SPM   │     │    glyph CLI     │
      │  GlyphPlugin     │     │ (JSON-RPC over   │
      │     Service      │     │  stdin/stdout)   │
      └──────────────────┘     └──────────────────┘
                │                        │
                └───────────┬────────────┘
                            │
                            ▼
              ┌───────────────────────────┐
              │ 40 Mobile-Safe Presets    │
              │ HierarchicalThemeFormatter│
              │ ProceduralMonolithGen     │
              │ TextWidthMetrics (≤24)    │
              └───────────────────────────┘
```

---

## 40 Production Presets Catalog

GLYPH comes pre-loaded with **40 mobile-safe templates** across 8 high-demand categories:
- **Wholesale & Merchant** (5 presets): `food_vault`, `butcher_reserves`, `coffee_roastery`, `raw_oyster_bar`, `luxury_fragrance`
- **Crypto & Alpha** (5 presets): `market_brief`, `syndicate_signals`, `token_radar`, `defi_harvest`, `whale_tracker`
- **VIP & Access** (5 presets): `vip_access`, `speakeasy_cipher`, `private_cellar`, `jet_charter`, `inner_sanctum`
- **Events & Nightlife** (5 presets): `nightclub_guestlist`, `warehouse_rave`, `boiler_room`, `afterhours_curfew`, `festival_timetable`
- **Cyber & Tech** (5 presets): `cyber_node`, `incident_postmortem`, `zeroday_advisory`, `fleet_deploy`, `hashrate_sentry`
- **Gaming & Esports** (5 presets): `clan_raid`, `scrim_schedule`, `meta_loadout`, `bounty_leaderboard`, `dropzone_tactics`
- **Health & Protocol** (5 presets): `daily_protocol`, `workout_block`, `recovery_stack`, `nootropic_stack`, `fasting_tracker`
- **Logistics & Dispatch** (5 presets): `dead_drop`, `courier_manifest`, `armored_transit`, `warehouse_stock`, `shift_handover`

Every preset is strictly guaranteed to conform to $\le 24$ visual columns with zero truncation.

---

## Option A: Native SPM Integration (Recommended for Speed & Simplicity)

### 1. Update `signal-auto-poster/Package.swift`

Add `glyph-studio` as a local package dependency:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SignalMacDaemon",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "SignalMacDaemon", targets: ["SignalMacDaemon"]),
    ],
    dependencies: [
        .package(path: "../glyph-studio"), // <--- Add local GLYPH package
    ],
    targets: [
        .target(
            name: "SignalMacDaemonLib",
            dependencies: [
                .product(name: "GLYPHCore", package: "glyph-studio") // <--- Link GLYPHCore
            ],
            path: "Sources/SignalMacDaemonLib"
        ),
        .executableTarget(
            name: "SignalMacDaemon",
            dependencies: ["SignalMacDaemonLib"],
            path: "Sources/SignalMacDaemon"
        ),
        .testTarget(
            name: "SignalMacDaemonTests",
            dependencies: ["SignalMacDaemonLib"],
            path: "Tests/SignalMacDaemonTests"
        ),
    ]
)
```

### 2. Direct Swift Usage in Signal Auto Poster

```swift
import GLYPHCore

// 1. List Presets
let presets = PresetsLibrary.allPresets
let wholesalePresets = PresetsLibrary.allPresets.filter { $0.category == "Wholesale & Merchant" }

// 2. Render Preset with Dynamic Variables
if let preset = PresetsLibrary.preset(for: "food_vault") {
    let broadcastText = preset.render(with: [
        "PRICE_OIL_DRUM": "$175.00",
        "PRICE_RICE": "$44.00"
    ], maxColumns: 24)
    print(broadcastText)
}

// 3. Format Arbitrary Text into Avant-Garde Hierarchical Layout
let doc = SemanticHierarchyParser.parse(rawText: userDraft)
let formatted = HierarchicalThemeFormatter.format(
    document: doc,
    theme: .obeliskGothic,
    fontStyle: .frakturBold
)

// 4. Validate Layout Safety for Mobile Signal Bubble
let validation = GlyphPluginService.shared.validateTextLayout(draft, maxColumns: 24)
if !validation.isSafe {
    // Auto-wrap across word boundaries without truncating words:
    let safeDraft = validation.safeWrappedText
}
```

---

## Option B: Out-of-Process Subprocess Plugin (CLI / JSON-RPC)

If you prefer out-of-process isolation, use the standalone `glyph` CLI binary:

### 1. Build and Install `glyph` binary

```bash
cd /Users/tb/Developer/apps/glyph-studio
make build-cli
# Or:
swift build -c release --product glyph
cp .build/release/glyph /usr/local/bin/glyph  # (or keep in bundle)
```

### 2. One-Shot JSON Invocation via Process

```swift
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/local/bin/glyph")
process.arguments = ["plugin"]

let stdinPipe = Pipe()
let stdoutPipe = Pipe()
process.standardInput = stdinPipe
process.standardOutput = stdoutPipe

try process.run()

let request = """
{
    "action": "render_preset",
    "presetId": "syndicate_signals",
    "variables": {
        "PAIR": "ETH / USD",
        "ENTRY": "$3,420"
    }
}
"""
stdinPipe.fileHandleForWriting.write(request.data(using: .utf8)!)
try stdinPipe.fileHandleForWriting.close()

let responseData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
let response = try JSONDecoder().decode(GlyphPluginResponse.self, from: responseData)
print(response.renderedText ?? "")
```

### 3. Persistent JSON-RPC Session

Launch `glyph rpc`. Over stdin, write newline-terminated JSON-RPC 2.0 messages:

```json
{"jsonrpc":"2.0","id":1,"method":"render_preset","params":{"action":"render_preset","presetId":"food_vault"}}
```

The daemon responds on stdout:

```json
{"id":1,"jsonrpc":"2.0","result":{"preset":{...},"renderedText":"...","success":true,"version":"1.0.0"}}
```

---

## Ready-to-Drop Plugin Client

A complete, asynchronous, zero-dependency plugin client is provided at [`docs/GlyphPluginClient.swift`](file:///Users/tb/Developer/apps/glyph-studio/docs/GlyphPluginClient.swift). Simply drop it into `signal-auto-poster/Sources/SignalMacDaemonLib/Services/` whenever you are ready to expose GLYPH in Signal Auto Poster!
