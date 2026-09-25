import Foundation

public struct SignalPostPreset: Identifiable, Sendable, Codable {
    public let id: String
    public let title: String
    public let category: String
    public let rawContent: String
    public let description: String
    public let tags: [String]
    public let variables: [String]
    
    public init(
        id: String,
        title: String,
        category: String,
        rawContent: String,
        description: String = "",
        tags: [String] = [],
        variables: [String] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.rawContent = rawContent
        self.description = description.isEmpty ? title : description
        self.tags = tags
        self.variables = variables.isEmpty ? PresetTemplateEngine.extractVariables(from: rawContent) : variables
    }
    
    /// Structured metadata for all variables in this preset (names and defaults)
    public var variableInfos: [PresetVariableInfo] {
        PresetTemplateEngine.extractVariableInfos(from: rawContent)
    }
    
    /// Default values specified in the template using {{VAR:-DEFAULT}} syntax
    public var defaultVariables: [String: String] {
        PresetTemplateEngine.extractDefaultValues(from: rawContent)
    }
    
    /// Renders the preset substituting any supplied variables and ensuring wrap safety (<= 24 cols)
    public func render(with variables: [String: String] = [:], maxColumns: Int = 24) -> String {
        return PresetTemplateEngine.render(template: rawContent, variables: variables, maxColumns: maxColumns)
    }
}

public struct PresetsLibrary: Sendable {
    
    /// Complete catalog of 40 museum-grade, mobile-safe (<= 24 cols) Signal presets across 8 distinct categories
    public static let allPresets: [SignalPostPreset] = [
        
        // =====================================================================
        // MARK: - 1. Wholesale & Merchant (5 Presets)
        // =====================================================================
        
        SignalPostPreset(
            id: "food_vault",
            title: "Tiered Inventory & Food Vault",
            category: "Wholesale & Merchant",
            rawContent: """
░░▒▒▓▓████████████▓▓▒▒░░
▓  ༺ 𝔉𝔒𝔒𝔇  𝔙𝔄𝔘𝔏𝔗 ༻  ▓
░░▒▒▓▓████████████▓▓▒▒░░

◈ EXTRA VIRGIN OLIVE OIL
  ┠ 500 mL (x12)
  ┃ ➔ $102.00 [$8.50/u]
  ┠ 3 L Tin (x4)
  ┃ ➔ $120.00 [$30/u]
  ┠ 20 L Drum (x1)
  ┃ ➔ {{PRICE_OIL_DRUM:-$165.00}}
  ╍╍╍╍╍ ❖ ╍╍╍╍╍

◈ JASMINE RICE A-GRADE
  ┠ 1 kg Bag (x10)
  ┃ ➔ $28.00 [$2.80/u]
  ┠ 5 kg Bag (x4)
  ┃ ➔ $44.00 [$11/u]
  ┠ 25 kg Sack (x1)
  ┃ ➔ {{PRICE_RICE:-$42.50}}
  ╍╍╍╍╍ ❖ ╍╍╍╍╍

◈ ALL-PURPOSE FLOUR
  ┠ 1 kg Bag (x12)
  ┃ ➔ $21.60 [$1.80/u]
  ┠ 12.5 kg Bag (x2)
  ┃ ➔ $32.00 [$16/u]
  ┠ 25 kg Sack (x1)
  ┃ ➔ {{PRICE_FLOUR:-$27.50}}

      ░▒▓█ 𖤍 █▓▒░
    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
""",
            description: "Tiered wholesale pantry staples with per-unit breakdowns and bulk drums.",
            tags: ["wholesale", "pantry", "inventory", "food"]
        ),
        
        SignalPostPreset(
            id: "butcher_reserves",
            title: "Heritage Butchery Allocation",
            category: "Wholesale & Merchant",
            rawContent: """
       𓆩 ⚔︎ 𓆪
╭━━━━━━━━━━━━━━━━━━━━╮
┃ 𝔅𝔘𝔗ℭℌ𝔈ℜ  ℜ𝔈𝔖𝔈ℜ𝔙𝔈𝔖 ┃
╰━━━━━━━━━━━━━━━━━━━━╯
◈ WAGYU A5 RIB CAP
  ┠ 250g Steak Cut
  ┃ ➔ $85.00
  ┠ 1 kg Prime Roast
  ┃ ➔ $310.00
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
◈ KUROBUTA PORK BELLY
  ┠ 500g Slab Cut
  ┃ ➔ $24.50
  ┠ 2 kg Whole Slab
  ┃ ➔ $88.00
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
◈ 45-DAY DRY-AGED BONE
  ┠ 800g Tomahawk Rib
  ┃ ➔ $95.00
┠ CUTS: HAND-TRIMMED
┠ DISPATCH: CHILLED ICE
┠ STATUS: {{STATUS:-IN STOCK}}
      ░▒▓█ 𖤍 █▓▒░
""",
            description: "Premium butcher shop cuts, dry-aged steaks, and wholesale meat slabs.",
            tags: ["meat", "butcher", "wagyu", "wholesale"]
        ),
        
        SignalPostPreset(
            id: "coffee_roastery",
            title: "Microlot Coffee Roastery",
            category: "Wholesale & Merchant",
            rawContent: """
        ☕︎ ❖ ☕︎
╔══════════════════════╗
║  𝔐ℑℭℜ𝔒𝔏𝔒𝔗  ℜ𝔒𝔄𝔖𝔗  ║
╚══════════════════════╝
◈ PANAMA GEISHA NATURAL
  ┠ 250g Whole Bean
  ┃ ➔ $42.00
  ┠ 1 kg Roaster Tin
  ┃ ➔ $150.00
  ───── ༓ ─────
◈ ETHIOPIA YIRGACHEFFE
  ┠ 250g Washed
  ┃ ➔ $18.50
  ┠ 1 kg Roaster Tin
  ┃ ➔ $64.00
  ───── ༓ ─────
◈ COLOMBIA PINK BOURBON
  ┠ 250g Honey Process
  ┃ ➔ $22.00
  ┠ 1 kg Roaster Tin
  ┃ ➔ $78.00
┠ ROAST DATE: {{ROAST_DATE:-FRESH TODAY}}
┠ PROFILE: LIGHT FILTER
""",
            description: "Specialty coffee roastery single-origin microlot offerings.",
            tags: ["coffee", "roastery", "beans", "cafe"]
        ),
        
        SignalPostPreset(
            id: "raw_oyster_bar",
            title: "Pacific Oyster & Raw Bar",
            category: "Wholesale & Merchant",
            rawContent: """
        𓆩 𖤍 𓆪
╭───── ❖ ─────╮
│ 𝔒𝔜𝔖𝔗𝔈ℜ  𝔙𝔄𝔘𝔏𝔗 │
╰───── ❖ ─────╯
✦ KUMAMOTO PACIFIC
  ├─ 1 Dozen Shucked
  └─► $48.00 [$4/u]
  ├─ 2 Dozen Tray
  └─► $90.00
  ───── ༓ ─────
✦ BELON EUROPEAN FLAT
  ├─ 6-Pack Harvest
  └─► $36.00
  ├─ 1 Dozen Harvest
  └─► $68.00
  ───── ༓ ─────
✦ OSETRA ROYAL CAVIAR
  ├─ 30g Vacuum Tin
  └─► $110.00
  ├─ 50g Prestige Tin
  └─► $175.00
┠ HARVEST: {{HARVEST:-COASTAL MORNING}}
┠ PACK: SHUCKED ON ICE
""",
            description: "Fresh raw bar oysters, shellfish, and royal caviar tins.",
            tags: ["seafood", "oysters", "caviar", "rawbar"]
        ),
        
        SignalPostPreset(
            id: "luxury_fragrance",
            title: "Artisanal Parfumerie & Attars",
            category: "Wholesale & Merchant",
            rawContent: """
       ꧁ ༺ ♔ ༻ ꧂
  ╔══════════════════╗
  ║    𝔒𝔘𝔇  𝔙𝔄𝔘𝔏𝔗    ║
  ╚══════════════════╝
◈ ROYAL CAMBODIAN OUD
  ├─ 3 mL Pure Attar
  └─ $140.00
  ├─ 12 mL Tola Crystal
  └─ $480.00
  ~ ~ ~ ❦ ~ ~ ~
◈ AMBERGRIS EXTRAIT
  ├─ 50 mL Flacon Spray
  └─ $260.00
  ~ ~ ~ ❦ ~ ~ ~
◈ TAIF ROSE CONCENTRATE
  ├─ 6 mL Decant Vial
  └─ $95.00
┠ AGING: 15-YEAR CASK
┠ ORIGIN: {{ORIGIN:-SOUTHEAST ASIA}}
       ꧁ ༺ ♔ ༻ ꧂
""",
            description: "Pure artisanal oud extracts, flacons, and concentrated attars.",
            tags: ["luxury", "perfume", "fragrance", "oud"]
        ),
        
        // =====================================================================
        // MARK: - 2. Crypto, Alpha & Trading (5 Presets)
        // =====================================================================
        
        SignalPostPreset(
            id: "market_brief",
            title: "The Alpha Market Briefing",
            category: "Crypto & Alpha",
            rawContent: """
             ▲
            ╱ ╲
           ╱ ◈ ╲
          ╱ ⚔︎ ⚔︎ ╲
         ╱ ░▒▓▒░ ╲
        ╱  𖤍 𖤍 𖤍  ╲
       ╱ ═════════ ╲
      ╱ 𝔐𝔄ℜ𝔎𝔈𝔗 𝔅ℜℑ𝔈𝔉 ╲
     ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
◈ BTC: {{BTC_PRICE:-$64,200}} [▲ 2.4%]
◈ ETH: {{ETH_PRICE:-$3,450}}  [▼ 0.8%]
◈ SOL: {{SOL_PRICE:-$152}}    [▲ 5.1%]
╍╍╍╍╍ ❖ ╍╍╍╍╍
KEY TAKEAWAYS:
• High volume on majors
• Breakout confirmation
• Tight stops enforced
        ▲   ▲
       ▲ ◈ ▲ ◈ ▲
        ▼   ▼
""",
            description: "Morning market snapshot with major crypto tickers and bias.",
            tags: ["crypto", "btc", "eth", "trading", "alpha"]
        ),
        
        SignalPostPreset(
            id: "syndicate_signals",
            title: "Syndicate Scalp Setup",
            category: "Crypto & Alpha",
            rawContent: """
╭━━━━━━━━━━━━━━━━━━━━╮
┃  𝔖𝔜𝔑𝔇ℑℭ𝔄𝔗𝔈  𝔈𝔑𝔗ℜ𝔜  ┃
╰━━━━━━━━━━━━━━━━━━━━╯
◈ PAIR: {{PAIR:-SOL / USD}}
◈ TYPE: {{ORDER_TYPE:-LONG SCALP}}
  ┠ ENTRY: {{ENTRY:-$148 - $151}}
  ┠ TARGET 1: {{TP1:-$158}}
  ┠ TARGET 2: {{TP2:-$166}}
  ┠ STOP: {{SL:-$144}}
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
LEVERAGE: 3x - 5x MAX
INVALIDATION: 4H CLOSE
BELOW $143.50
 ░▒▓█ 𖤍 █▓▒░
""",
            description: "High-probability scalp entry with precise stop-loss and targets.",
            tags: ["signals", "scalp", "futures", "leverage"]
        ),
        
        SignalPostPreset(
            id: "token_radar",
            title: "Stealth Token Launch Radar",
            category: "Crypto & Alpha",
            rawContent: """
┌───[ ⬡ ⌬ ⬡ ]───┐
│ ░▒▓  𝔏𝔄𝔘𝔑ℭℌ ℜ𝔄𝔇𝔄ℜ  ▓▒░ │
└───[ ⬡ ⌬ ⬡ ]───┘
  ⚡︎ ─ ─ ─ ─ ─ ─ ⚡︎
═━═[ ⏣ NEW POOL ⏣ ]═━═
◈ TICKER: {{TICKER:-$NEXUS}}
◈ CHAIN: {{CHAIN:-SOLANA}}
◈ MCAP: {{MCAP:-$140K}}
◈ LIQUIDITY: {{LIQ:-$65K (BURNED)}}
◈ TAX: 0% BUY / 0% SELL
  ─ ─ ─ ─ ⌬ ─ ─ ─ ─
CONTRACT VERIFIED:
CA: {{CA:-8xR4...k9Pq}}
AUDIT: MINT REVOKED
  ⚡︎ ─ ─ ─ ─ ─ ─ ⚡︎
""",
            description: "Early stealth coin launch scanner and safety verification.",
            tags: ["memecoin", "dex", "launch", "solana"]
        ),
        
        SignalPostPreset(
            id: "defi_harvest",
            title: "Cross-Chain DeFi Yield Farm",
            category: "Crypto & Alpha",
            rawContent: """
        ★ ✵ ✧ ✦
╭─── ✦ 𝔜ℑ𝔈𝔏𝔇 𝔉𝔄ℜ𝔐 ✦ ───╮
╰──────────────────────╯
◈ PROTOCOL: {{PROTOCOL:-KAMINO VAULT}}
◈ ASSET: SOL-USDC LP
  ┠ BASE APY: 18.4%
  ┠ REWARD BOOST: +6.2%
  ┃ ➔ TOTAL: {{TOTAL_APY:-24.6% APY}}
  · · · ✵ · · ·
◈ STRATEGY: AUTO-COMPOUND
◈ LOCKUP: NONE (LIQUID)
◈ RISK TIER: MODERATE
★ ━━━━━━━━━━━━━━━━━━━━ ★
TVL: {{TVL:-$42.8M}}
""",
            description: "High-yield liquidity pool and yield farm monitoring card.",
            tags: ["defi", "yield", "apy", "farming"]
        ),
        
        SignalPostPreset(
            id: "whale_tracker",
            title: "Whale Treasury Alert",
            category: "Crypto & Alpha",
            rawContent: """
░▒▓██████████████████▓▒░
▓▒  ༺ 𝔚ℌ𝔄𝔏𝔈 𝔖𝔈𝔑𝔗ℜ𝔜 ༻  ▒▓
░▒▓██████████████████▓▒░
◈ MOVEMENT DETECTED:
  ┠ ASSET: {{WHALE_ASSET:-BTC}}
  ┠ AMOUNT: {{WHALE_AMT:-2,500 COINS}}
  ┠ USD VALUE: {{WHALE_VAL:-$160.5M}}
  ┃ ➔ FLOW: COLD -> BINANCE
▓▒░ ◈ ❖ WARNING ❖ ◈ ░▒▓
POTENTIAL SELL PRESSURE
MONITOR $63.8K SUPPORT
TIMESTAMP: {{TIME:-JUST NOW}}
░▒▓██████████████████▓▒░
""",
            description: "Whale wallet exchange inflow alert and liquidation risk.",
            tags: ["whale", "onchain", "alert", "tracker"]
        ),
        
        // =====================================================================
        // MARK: - 3. VIP, Private Access & Concierge (5 Presets)
        // =====================================================================
        
        SignalPostPreset(
            id: "vip_access",
            title: "Private Key & Access Pass",
            category: "VIP & Access",
            rawContent: """
░░▒▒▓▓████████████▓▓▒▒░░
▓  ༺  𝔙ℑ𝔓  𝔄ℭℭ𝔈𝔖𝔖  ༻  ▓
░░▒▒▓▓████████████▓▓▒▒░░

◈ PASSPHRASE VERIFIED
◈ TIER: {{TIER:-INNER CIRCLE}}
◈ CLEARANCE: LEVEL 4
╍╍╍╍╍ ❖ ╍╍╍╍╍
  ┠ SESSION: 24 HOURS
  ┠ PROXY: ROTATING
  ┠ ENCRYPTION: E2E
  ┃ ➔ STATUS: {{STATUS:-ACTIVE}}
      ░▒▓█ 𖤍 █▓▒░
""",
            description: "High-security passphrase authorization token card.",
            tags: ["vip", "access", "passphrase", "security"]
        ),
        
        SignalPostPreset(
            id: "speakeasy_cipher",
            title: "Speakeasy Midnight Cipher",
            category: "VIP & Access",
            rawContent: """
        ☉ ☽ ☿
╔══════════════════════╗
║   ༺ 𝔐ℑ𝔇𝔑ℑ𝔊ℌ𝔗 ༻   ║
╚══════════════════════╝
        ᚛ ༒ ᚜
◈ DOOR CODE: {{DOOR_CODE:-#8402*}}
◈ KNOCK: 3 SHORT, 1 LONG
◈ PASSPHRASE:
  ├─ "{{CIPHER:-OBSIDIAN MIRROR}}"
  └─► VALID UNTIL 04:00
  ───── ༓ ─────
◈ BAR DRESS CODE:
  ├─ STRICT BLACK TIE
  └─ NO FLASH / PHONES
        ᚛ ༒ ᚜
╚══════════════════════╝
""",
            description: "Exclusive speakeasy entrance passcode and door rules.",
            tags: ["speakeasy", "nightlife", "secret", "vip"]
        ),
        
        SignalPostPreset(
            id: "private_cellar",
            title: "Private Cellar Vintage Allocation",
            category: "VIP & Access",
            rawContent: """
       ꧁ ༺ ♔ ༻ ꧂
  ╔══════════════════╗
  ║  ℭ𝔈𝔏𝔏𝔄ℜ  𝔙𝔄𝔘𝔏𝔗  ║
  ╚══════════════════╝
◈ 2010 DOM PÉRIGNON OEN
  ├─ 3 Bottles Reserved
  └─ $520.00/bottle
  ~ ~ ~ ❦ ~ ~ ~
◈ 2015 CHÂTEAU MARGAUX
  ├─ Premier Grand Cru
  └─ $890.00/bottle
  ~ ~ ~ ❦ ~ ~ ~
◈ 1996 CHÂTEAU D'YQUEM
  ├─ 375 mL Half Bottle
  └─ $410.00
┠ CELLAR TEMP: 12.8°C
┠ ALLOCATION: {{ALLOCATION:-2 SLOTS REMAIN}}
       ꧁ ༺ ♔ ༻ ꧂
""",
            description: "Rare vintage fine wine allocation card for high-net-worth cellars.",
            tags: ["wine", "vintage", "champagne", "luxury"]
        ),
        
        SignalPostPreset(
            id: "jet_charter",
            title: "Private Jet Empty-Leg Alert",
            category: "VIP & Access",
            rawContent: """
╭━━━━━━━━━━━━━━━━━━━━╮
┃ 𝔓ℜℑ𝔙𝔄𝔗𝔈  𝔉𝔏ℑ𝔊ℌ𝔗 ┃
╰━━━━━━━━━━━━━━━━━━━━╯
◈ ROUTE: {{ORIGIN:-SYD}} ➔ {{DEST:-MEL}}
◈ AIRCRAFT: CITATION X
◈ DATE: {{FLIGHT_DATE:-TOMORROW 14:00}}
◈ SEATS: {{SEATS:-6 PASSENGERS}}
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
  ┠ CHARTER: $4,800 FLAT
  ┠ CATERING: INCLUDED
  ┠ FBO: JET AVIATION
  ┃ ➔ BOOK: @CONCIERGE
 ░▒▓█ 𖤍 █▓▒░
""",
            description: "Fast-filling private jet empty-leg charter seat broadcast.",
            tags: ["aviation", "jet", "travel", "vip"]
        ),
        
        SignalPostPreset(
            id: "inner_sanctum",
            title: "Executive Board Briefing",
            category: "VIP & Access",
            rawContent: """
      ᚛ ᚠ ᚢ ᚦ ᚨ ᚱ ᚜
  ╔══════════════════╗
  ║    𝔖𝔄𝔑ℭ𝔗𝔘𝔐     ║
  ╚══════════════════╝
◈ BOARD AGENDA: Q4 VOTE
◈ TIME: {{TIME:-20:00 UTC}}
◈ QUORUM: 7 OF 9 SIGNED
  ┠ MOTION: ACQUISITION
  ┠ TREASURY DRAW: $2.4M
  ┃ ➔ KEY: {{KEY:-0x9F...31E}}
  ╍╍╍ ᛟ ╍╍╍
CONFIDENTIAL / DESTROY
      ᚛ ᚠ ᚢ ᚦ ᚨ ᚱ ᚜
""",
            description: "Encrypted executive board docket and quorum validation pass.",
            tags: ["board", "executive", "dao", "confidential"]
        ),
        
        // =====================================================================
        // MARK: - 4. Underground Events & Nightlife (5 Presets)
        // =====================================================================
        
        SignalPostPreset(
            id: "nightclub_guestlist",
            title: "Nightclub Guestlist RSVP",
            category: "Events & Nightlife",
            rawContent: """
       ꧁ ༺ ♔ ༻ ꧂
  ╔══════════════════╗
  ║    𝔖𝔄𝔑ℭ𝔗𝔘𝔄ℜ𝔜    ║
  ╚══════════════════╝
◈ {{EVENT_NAME:-FRIDAY NIGHT EXCLUSIVE}}
◈ DOORS: {{DOORS:-23:00 SHARP}}
◈ DRESS: ALL BLACK
╍╍╍╍╍ ❖ ╍╍╍╍╍
  ┠ VIP TABLE 1-4: FULL
  ┠ VIP TABLE 5-8: HOLD
  ┠ MEZZANINE: OPEN
  ┃ ➔ RSVP: {{CONTACT:-@CONCIERGE}}
       ꧁ ༺ ♔ ༻ ꧂
""",
            description: "VIP nightclub table reservation and guestlist RSVP card.",
            tags: ["nightclub", "guestlist", "vip", "rsvp"]
        ),
        
        SignalPostPreset(
            id: "warehouse_rave",
            title: "Underground Warehouse Protocol",
            category: "Events & Nightlife",
            rawContent: """
┌───[ ⬡ ⌬ ⬡ ]───┐
│ ░▒▓  𝔚𝔄ℜ𝔈ℌ𝔒𝔘𝔖𝔈  ▓▒░ │
└───[ ⬡ ⌬ ⬡ ]───┘
◈ SOUND: FUNKTION-ONE
◈ GENRE: INDUSTRIAL TECHNO
◈ VENUE: REVEALED AT 21:00
  ╟── LOCATION: {{REGION:-PORT BOTANY}}
  ╚═▶ [ {{ENTRY_FEE:-$35 ENTRY}} ]
  ─ ─ ─ ─ ⌬ ─ ─ ─ ─
RULES:
1. NO CAMERAS / NO STICKERS
2. RESPECT THE SPACE
3. RADICAL DANCE
  ⚡︎ ─ ─ ─ ─ ─ ─ ⚡︎
""",
            description: "Secret warehouse rave coordinates, sound system, and house rules.",
            tags: ["rave", "techno", "warehouse", "underground"]
        ),
        
        SignalPostPreset(
            id: "boiler_room",
            title: "Secret Boiler Room Timetable",
            category: "Events & Nightlife",
            rawContent: """
╭━━━━━━━━━━━━━━━━━━━━╮
┃  𝔅𝔒ℑ𝔏𝔈ℜ  ℜ𝔒𝔒𝔐  ┃
╰━━━━━━━━━━━━━━━━━━━━╯
◈ LINEUP & SET TIMES:
  ┠ 22:00 - {{DJ1:-HYPERION}}
  ┠ 23:30 - {{DJ2:-KORVEX (LIVE)}}
  ┠ 01:00 - {{DJ3:-NEOX B2B VEX}}
  ┃ ➔ 03:00 - SURPRISE GUEST
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
BROADCAST: 360° LIVE
CAPACITY: {{CAPACITY:-150 ONLY}}
 ░▒▓█ 𖤍 █▓▒░
""",
            description: "Set times timetable for 360-degree intimate DJ broadcast sessions.",
            tags: ["dj", "music", "boilerroom", "lineup"]
        ),
        
        SignalPostPreset(
            id: "afterhours_curfew",
            title: "Private Afterhours Curfew",
            category: "Events & Nightlife",
            rawContent: """
        ☉ ☽ ☿
╔══════════════════════╗
║   ༺ 𝔄𝔉𝔗𝔈ℜ𝔖 ༻   ║
╚══════════════════════╝
◈ HOURS: 03:30 - 10:00
◈ ENTRY: PASSWORD ONLY
◈ DOORMAN: HAS FINAL SAY
  ├─ CHILLOUT SANCTUM
  ├─ HYDRATION BAR
  └─► ELECTROLYTES ON TAP
  ───── ༓ ─────
LOCATION PING:
{{LOCATION:-SECRET LOFT W3}}
        ☉ ☽ ☿
""",
            description: "Late-night afterhours lounge pass and door curation instructions.",
            tags: ["afterhours", "night", "club", "private"]
        ),
        
        SignalPostPreset(
            id: "festival_timetable",
            title: "Main Stage Festival Timetable",
            category: "Events & Nightlife",
            rawContent: """
░▒▓██████████████████▓▒░
▓▒  ༺ 𝔐𝔄ℑ𝔑 𝔖𝔗𝔄𝔊𝔈 ༻  ▒▓
░▒▓██████████████████▓▒░
◈ TODAY'S RUNNING ORDER:
  ┠ 16:00 - WARMUP GROOVE
  ┠ 18:00 - SUNSET SYMPHONY
  ┠ 20:30 - {{HEADLINER1:-SUB FOCUS}}
  ┃ ➔ 22:30 - {{HEADLINER2:-CHASE & STATUS}}
▓▒░ ◈ ❖ ENCORE ❖ ◈ ░▒▓
GATE LOCK: MIDNIGHT
LOST & FOUND: TENT 4
░▒▓██████████████████▓▒░
""",
            description: "Festival headliner schedule and main stage running order.",
            tags: ["festival", "concert", "timetable", "music"]
        ),
        
        // =====================================================================
        // MARK: - 5. Cyber, Sysadmin & Infrastructure (5 Presets)
        // =====================================================================
        
        SignalPostPreset(
            id: "cyber_node",
            title: "Cyber Conduit Network Status",
            category: "Cyber & Tech",
            rawContent: """
┌───[ ⬡ ⌬ ⬡ ]───┐
│ ░▒▓  𝔑𝔒𝔇𝔈 𝔘𝔓𝔏ℑ𝔑𝔎  ▓▒░ │
└───[ ⬡ ⌬ ⬡ ]───┘
  ⚡︎ ─ ─ ─ ─ ─ ─ ⚡︎
═━═[ ⏣ MAINNET CLUSTER ⏣ ]═━═
╔═[ ⚡︎ COMPUTE RIG 01 ]═╗
⌬ H100 SXM5 CLUSTER
  ╟── HASHRATE: {{HASHRATE:-3.2 PF}}
  ╚═▶ [ {{PRICE_HR:-$4.20/HR}} ]
⌬ A100 80GB POD
  ╟── LATENCY: {{PING:-1.4ms}}
  ╚═▶ [ $1.85/HR ]
╚══════════════════════╝
  ⚡︎ ─ ─ ─ ─ ─ ─ ⚡︎
└───[ ⬡ TERMINATION ⬡ ]───┘
""",
            description: "GPU cluster hashrate, node status, and cloud rental costs.",
            tags: ["gpu", "server", "infra", "sysadmin"]
        ),
        
        SignalPostPreset(
            id: "incident_postmortem",
            title: "P1 Incident Outage Postmortem",
            category: "Cyber & Tech",
            rawContent: """
╭━━━━━━━━━━━━━━━━━━━━╮
┃  𝔒𝔘𝔗𝔄𝔊𝔈  ℜ𝔈𝔓𝔒ℜ𝔗  ┃
╰━━━━━━━━━━━━━━━━━━━━╯
◈ INCIDENT: {{INCIDENT_ID:-INC-8921}}
◈ SEVERITY: P1 CRITICAL
◈ DURATION: {{DURATION:-18 MINUTES}}
  ┠ AFFECTED: API GATEWAY
  ┠ ROOT CAUSE: DB POOL
  ┃ ➔ STATUS: {{STATUS:-RESOLVED}}
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
ACTION ITEMS:
• BUMP DB CONNECTION POOL
• DEPLOY CIRCUIT BREAKER
• POSTMORTEM CALL AT 11:00
 ░▒▓█ 𖤍 █▓▒░
""",
            description: "Immediate incident resolution report and action item checklist.",
            tags: ["incident", "devops", "sre", "outage"]
        ),
        
        SignalPostPreset(
            id: "zeroday_advisory",
            title: "Zero-Day Vulnerability Advisory",
            category: "Cyber & Tech",
            rawContent: """
             ▲
            ╱ ╲
           ╱ ◈ ╲
          ╱ ⚔︎ ⚔︎ ╲
         ╱ ░▒▓▒░ ╲
        ╱  𖤍 𖤍 𖤍  ╲
       ╱ ═════════ ╲
      ╱ 𝔖𝔈ℭ𝔘ℜℑ𝔗𝔜 𝔄𝔏𝔈ℜ𝔗 ╲
     ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
◈ CVE: {{CVE_ID:-CVE-2026-4921}}
◈ CVSS: {{CVSS_SCORE:-9.8 CRITICAL}}
◈ VECTOR: REMOTE RCE
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
┠ TARGET: OPENSSH / GLIBC
┠ MITIGATION: APPLY HOTFIX
┠ DEADLINE: IMMEDIATE
        ▲   ▲
       ▲ ◈ ▲ ◈ ▲
        ▼   ▼
""",
            description: "High-priority security patch notice for sysadmins and DevOps.",
            tags: ["security", "cve", "infosec", "patch"]
        ),
        
        SignalPostPreset(
            id: "fleet_deploy",
            title: "Kubernetes Fleet Deployment",
            category: "Cyber & Tech",
            rawContent: """
        𓆩 ⚡︎ 𓆪
╭━━━━━━━━━━━━━━━━━━━━╮
┃ 𝔉𝔏𝔈𝔈𝔗  ℜ𝔒𝔏𝔏𝔒𝔘𝔗 ┃
╰━━━━━━━━━━━━━━━━━━━━╯
◈ SERVICE: {{SERVICE_NAME:-AUTH-SERVICE}}
◈ VERSION: {{VERSION_TAG:-v2.14.0}}
◈ CANARY: 100% HEALTHY
  ┠ CLUSTER: US-EAST-1
  ┠ POD COUNT: 64/64
  ┃ ➔ ERROR RATE: 0.001%
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
ROLLBACK READY: REVISION 42
DEPLOYED BY: {{OPERATOR:-@RELEASE_BOT}}
""",
            description: "Cloud container deployment progress and health metrics.",
            tags: ["kubernetes", "deploy", "docker", "cloud"]
        ),
        
        SignalPostPreset(
            id: "hashrate_sentry",
            title: "Mining Pool Hashrate Sentry",
            category: "Cyber & Tech",
            rawContent: """
        ★ ✵ ✧ ✦
╭─── ✦ ℌ𝔄𝔖ℌℜ𝔄𝔗𝔈 ✦ ───╮
╰──────────────────────╯
◈ POOL: {{POOL_NAME:-ANTMINER S21 FLEET}}
◈ TOTAL: {{POOL_HASHRATE:-14.2 EH/s}}
◈ EFFICIENCY: 17.5 J/TH
  · · · ✵ · · ·
◈ ACTIVE RIGS: 1,240
◈ DOWNED RIGS: 3
◈ 24H REWARD: {{REWARD_BTC:-2.84 BTC}}
★ ━━━━━━━━━━━━━━━━━━━━ ★
STATUS: NOMINAL
""",
            description: "Bitcoin mining rig farm telemetry and daily reward counter.",
            tags: ["mining", "bitcoin", "asic", "hardware"]
        ),
        
        // =====================================================================
        // MARK: - 6. Gaming, Raids & Esports (5 Presets)
        // =====================================================================
        
        SignalPostPreset(
            id: "clan_raid",
            title: "Mythic Clan Raid Squad",
            category: "Gaming & Esports",
            rawContent: """
       𓆩 ⚔︎ 𓆪
╭━━━━━━━━━━━━━━━━━━━━╮
┃ 𝔐𝔜𝔗ℌℑℭ  ℜ𝔄ℑ𝔇  ┃
╰━━━━━━━━━━━━━━━━━━━━╯
◈ RAID: {{RAID_NAME:-ABYSSAL CITADEL}}
◈ PULL TIME: {{PULL_TIME:-20:00 EST}}
◈ ROSTER ASSIGNMENTS:
  ┠ MAIN TANK: @VORTEX
  ┠ OFF TANK: @TITAN
  ┠ LEAD HEAL: @AEGIS
  ┃ ➔ TOP DPS: @SPECTRE
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
CONSUMABLES REQUIRED:
• 2x FLASK OF POWER
• 20x POTION OF BURST
• REPAIR BOT STAGED
""",
            description: "MMO raid squad roster, buff food requirements, and pull time.",
            tags: ["gaming", "raid", "mmo", "clan"]
        ),
        
        SignalPostPreset(
            id: "scrim_schedule",
            title: "Tier 1 Esports Scrim Schedule",
            category: "Gaming & Esports",
            rawContent: """
┌───[ ⬡ ⌬ ⬡ ]───┐
│ ░▒▓  𝔖ℭℜℑ𝔐 𝔅𝔏𝔒ℭ𝔎  ▓▒░ │
└───[ ⬡ ⌬ ⬡ ]───┘
◈ OPPONENT: {{OPPONENT:-TEAM LIQUID}}
◈ TIME: {{SCRIM_TIME:-19:00 CET}}
◈ MAP POOL:
  ╟── MAP 1: INFERNO
  ╟── MAP 2: ANUBIS
  ╚═▶ [ MAP 3: MIRAGE ]
  ─ ─ ─ ─ ⌬ ─ ─ ─ ─
SERVER: FRANKFURT 128T
WARMUP IN DISCORD: 18:30
COACH: @ANALYST
""",
            description: "Competitive tactical shooter scrim block and map selection.",
            tags: ["esports", "scrim", "cs2", "valorant"]
        ),
        
        SignalPostPreset(
            id: "meta_loadout",
            title: "Warzone Meta Weapon Loadout",
            category: "Gaming & Esports",
            rawContent: """
        𓆩 ⚡︎ 𓆪
╭───── ❖ ─────╮
│ 𝔐𝔈𝔗𝔄  𝔅𝔘ℑ𝔏𝔇 │
╰───── ❖ ─────╯
✦ {{PRIMARY_WEAPON:-RAM-7 ASSAULT RIFLE}}
  ├─ MUZZLE: SONIC SUPPRESSOR
  ├─ BARREL: CRONEN HEADWIND
  ├─ OPTIC: CORIO EAGLESEYE
  ├─ MAG: 60 ROUND DRUM
  └─► STOCK: HVS 3.4 PAD
  ───── ༓ ─────
✦ SECONDARY: HRM-9 SMG
  ├─ MOBILITY TUNING
  └─► HIPFIRE SPREAD MIN
TTK: {{TTK:-580ms}}
""",
            description: "Optimized weapon attachment tuning and TTK calculation.",
            tags: ["warzone", "cod", "loadout", "fps"]
        ),
        
        SignalPostPreset(
            id: "bounty_leaderboard",
            title: "Kill Bounty & Tournament Ladder",
            category: "Gaming & Esports",
            rawContent: """
░▒▓██████████████████▓▒░
▓▒  ༺ 𝔏𝔈𝔄𝔇𝔈ℜ𝔅𝔒𝔄ℜ𝔇 ༻  ▒▓
░▒▓██████████████████▓▒░
◈ ROUND {{ROUND_NUM:-3}} STANDINGS:
  ┠ #1 {{P1:-@RAZOR}} (18 KILLS)
  ┠ #2 {{P2:-@WRAITH}} (14 KILLS)
  ┠ #3 {{P3:-@GHOST}} (11 KILLS)
  ┃ ➔ BOUNTY PURSE: {{BOUNTY_POOL:-$5,000}}
▓▒░ ◈ ❖ FINAL CIRCLE ❖ ◈ ░▒▓
STREAM: TWITCH.TV/ARENA
NEXT LOBBY: 10 MINS
░▒▓██████████████████▓▒░
""",
            description: "Tournament frag leaderboard and live prize pool tracking.",
            tags: ["tournament", "leaderboard", "bounty", "esports"]
        ),
        
        SignalPostPreset(
            id: "dropzone_tactics",
            title: "Battle Royale Dropzone Strategy",
            category: "Gaming & Esports",
            rawContent: """
      ᚛ ᚠ ᚢ ᚦ ᚨ ᚱ ᚜
  ╔══════════════════╗
  ║    𝔇ℜ𝔒𝔓  𝔏ℨ     ║
  ╚══════════════════╝
◈ PRIMARY LZ: {{LZ:-SUPERSTORE ROOF}}
◈ FALLBACK: STORAGE TOWN
◈ PRIORITY OBJECTIVES:
  ┠ FAST SCAVENGER CONTRACT
  ┠ BUY LOADOUT DROP ($10K)
  ┃ ➔ HOLD HIGH GROUND
  ╍╍╍ ᛟ ╍╍╍
CALLOUT: WATCH PINGS
      ᚛ ᚠ ᚢ ᚦ ᚨ ᚱ ᚜
""",
            description: "Team landing zone tactics, buy station plan, and rotation routes.",
            tags: ["battleroyale", "dropzone", "tactics", "squad"]
        ),
        
        // =====================================================================
        // MARK: - 7. Health, Protocol & Biohacking (5 Presets)
        // =====================================================================
        
        SignalPostPreset(
            id: "daily_protocol",
            title: "Executive Biohacking Protocol",
            category: "Health & Protocol",
            rawContent: """
        ☉ ☽ ☿
╔══════════════════════╗
║   ༺ 𝔓ℜ𝔒𝔗𝔒ℭ𝔒𝔏 ༻   ║
╚══════════════════════╝
◈ MORNING OPTIMIZATION:
  ├─ 15 MIN SUNLIGHT EXP
  ├─ 500 mL WATER + 2g SALT
  ├─ 3 MIN COLD SHOWER
  └─► DELAY CAFFEINE 90M
  ───── ༓ ─────
◈ ZONE 2 CARDIO:
  ├─ 45 MIN NOSE BREATHING
  └─► TARGET HR: {{TARGET_HR:-135 BPM}}
OXYGEN SAT: {{SPO2:-99%}}
        ☉ ☽ ☿
""",
            description: "Circadian rhythm alignment, morning sunlight, and hydration rules.",
            tags: ["biohacking", "health", "huberman", "morning"]
        ),
        
        SignalPostPreset(
            id: "workout_block",
            title: "Strength Hypertrophy Block",
            category: "Health & Protocol",
            rawContent: """
╭━━━━━━━━━━━━━━━━━━━━╮
┃ 𝔏ℑ𝔉𝔗ℑ𝔑𝔊  𝔅𝔏𝔒ℭ𝔎 ┃
╰━━━━━━━━━━━━━━━━━━━━╯
◈ FOCUS: {{FOCUS:-UPPER HEAVY}}
  ┠ BENCH PRESS (4x6 @80%)
  ┠ WEIGHTED CHINS (4x8)
  ┠ OVERHEAD PRESS (3x8)
  ┃ ➔ INCLINE DB CURLS
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
REST: 2.5 MIN BETWEEN SETS
RPE CEILING: 8.5
POST-WORKOUT: 40g ISOLATE
 ░▒▓█ 𖤍 █▓▒░
""",
            description: "Compound strength training split with RPE targets and rest timers.",
            tags: ["fitness", "lifting", "gym", "strength"]
        ),
        
        SignalPostPreset(
            id: "recovery_stack",
            title: "Contrast Therapy & Sauna Routine",
            category: "Health & Protocol",
            rawContent: """
        ★ ✵ ✧ ✦
╭─── ✦ ℜ𝔈ℭ𝔒𝔙𝔈ℜ𝔜 ✦ ───╮
╰──────────────────────╯
◈ CONTRAST THERAPY PROTOCOL:
  ┠ SAUNA: {{SAUNA_TEMP:-90°C}} (20 MIN)
  ┠ PLUNGE: {{PLUNGE_TEMP:-4°C}} (3 MIN)
  ┠ REPEAT: 3 FULL CYCLES
  ┃ ➔ FINISH ON COLD
  · · · ✵ · · ·
HRV STATUS: {{HRV:-74ms (HIGH)}}
SLEEP SCORE: {{SLEEP:-91% RECHARGED}}
★ ━━━━━━━━━━━━━━━━━━━━ ★
""",
            description: "Cold plunge and Finnish sauna thermal shock protocol.",
            tags: ["recovery", "sauna", "coldplunge", "hrv"]
        ),
        
        SignalPostPreset(
            id: "nootropic_stack",
            title: "Cognitive Nootropic Stack",
            category: "Health & Protocol",
            rawContent: """
┌───[ ⬡ ⌬ ⬡ ]───┐
│ ░▒▓  𝔑𝔒𝔒𝔗ℜ𝔒𝔓ℑℭ  ▓▒░ │
└───[ ⬡ ⌬ ⬡ ]───┘
◈ MORNING FOCUS CONDUIT:
  ╟── ALPHA-GPC: 300mg
  ╟── L-TYROSINE: 1,000mg
  ╟── L-THEANINE: 200mg
  ╚═▶ [ LION'S MANE: 500mg ]
  ─ ─ ─ ─ ⌬ ─ ─ ─ ─
MEAL TIMING: FASTED
HYDRATION: ADD ELECTROLYTE
COGNITIVE READINESS: PEAK
  ⚡︎ ─ ─ ─ ─ ─ ─ ⚡︎
""",
            description: "Fasted morning neurochemical modulation and focus stack.",
            tags: ["nootropics", "supplements", "focus", "brain"]
        ),
        
        SignalPostPreset(
            id: "fasting_tracker",
            title: "Intermittent Fasting Autophagy",
            category: "Health & Protocol",
            rawContent: """
░▒▓██████████████████▓▒░
▓▒  ༺  𝔉𝔄𝔖𝔗ℑ𝔑𝔊  ༻  ▒▓
░▒▓██████████████████▓▒░
◈ WINDOW: {{FAST_HOURS:-18 / 6 PROTOCOL}}
◈ FAST STARTED: 20:00
◈ BREAKFAST AT: {{EAT_TIME:-14:00}}
  ┠ CURRENT ELAPSED: 16H
  ┠ GLUCOSE: 4.8 mmol/L
  ┃ ➔ AUTOPHAGY: ACTIVE
▓▒░ ◈ ❖ LIQUIDS ❖ ◈ ░▒▓
BLACK COFFEE, WATER, TEA
░▒▓██████████████████▓▒░
""",
            description: "Fast countdown, autophagy phase indicator, and glucose checks.",
            tags: ["fasting", "diet", "autophagy", "health"]
        ),
        
        // =====================================================================
        // MARK: - 8. Logistics, Couriers & Dispatch (5 Presets)
        // =====================================================================
        
        SignalPostPreset(
            id: "dead_drop",
            title: "Encrypted Dead-Drop Coordinate",
            category: "Logistics & Dispatch",
            rawContent: """
             ▲
            ╱ ╲
           ╱ ◈ ╲
          ╱ ⚔︎ ⚔︎ ╲
         ╱ ░▒▓▒░ ╲
        ╱  𖤍 𖤍 𖤍  ╲
       ╱ ═════════ ╲
      ╱ 𝔇𝔈𝔄𝔇 𝔇ℜ𝔒𝔓 ╲
     ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
◈ GRID: {{COORDINATES:-33.8688° S, 151.2093° E}}
◈ OBJECT: MAGNETIC BOX
◈ RETRIEVAL WINDOW:
  ┠ FROM: {{TIME_FROM:-22:00}}
  ┃ ➔ UNTIL: {{TIME_UNTIL:-02:00 SHARP}}
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
CODE: {{PASSCODE:-#9021}}
VERIFY SEAL INTACT
""",
            description: "Secure dead-drop location coordinates and time window.",
            tags: ["deaddrop", "security", "courier", "gps"]
        ),
        
        SignalPostPreset(
            id: "courier_manifest",
            title: "Express Courier Manifest",
            category: "Logistics & Dispatch",
            rawContent: """
╭━━━━━━━━━━━━━━━━━━━━╮
┃  ℭ𝔒𝔘ℜℑ𝔈ℜ  ℜ𝔘𝔑  ┃
╰━━━━━━━━━━━━━━━━━━━━╯
◈ RUN ID: {{RUN_ID:-CR-49102}}
◈ COURIER: {{COURIER_NAME:-UNIT 7}}
◈ STOPS & PARCELS:
  ┠ STOP 1: CBD HUB (1x)
  ┠ STOP 2: DOCKLANDS (2x)
  ┃ ➔ STOP 3: AIRPORT FBO
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
TRANSIT STATUS: EN ROUTE
DISPATCH ETA: {{ETA:-18:45}}
SIGNATURE: REQUIRED
 ░▒▓█ 𖤍 █▓▒░
""",
            description: "Multi-stop courier delivery manifest and route coordination.",
            tags: ["courier", "delivery", "logistics", "dispatch"]
        ),
        
        SignalPostPreset(
            id: "armored_transit",
            title: "Armored Transit Checkpoint",
            category: "Logistics & Dispatch",
            rawContent: """
      ᚛ ᚠ ᚢ ᚦ ᚨ ᚱ ᚜
  ╔══════════════════╗
  ║   ℭ𝔒𝔑𝔙𝔒𝔜  𝔓ℑ𝔑𝔊   ║
  ╚══════════════════╝
◈ ESCORT CODE: {{CONVOY_CODE:-EAGLE-1}}
◈ CHECKPOINT: {{CHECKPOINT:-ALPHA CHECKPOINT}}
◈ STATUS: ALL GREEN
  ┠ SPEED: 80 KM/H
  ┠ FUEL RESERVE: 92%
  ┃ ➔ ETA TO DEST: {{DEST_ETA:-28 MINS}}
  ╍╍╍ ᛟ ╍╍╍
VAULT STATUS: LOCKED
COMM CHANNEL: SECURE
      ᚛ ᚠ ᚢ ᚦ ᚨ ᚱ ᚜
""",
            description: "High-value asset armored transport telemetry and checkpoint check-in.",
            tags: ["transport", "convoy", "security", "armored"]
        ),
        
        SignalPostPreset(
            id: "warehouse_stock",
            title: "Inventory Depletion Warning",
            category: "Logistics & Dispatch",
            rawContent: """
        𓆩 ⚡︎ 𓆪
╭───── ❖ ─────╮
│ 𝔖𝔗𝔒ℭ𝔎  𝔄𝔏𝔈ℜ𝔗 │
╰───── ❖ ─────╯
✦ {{DEPLETED_ITEM:-EXTRA VIRGIN OLIVE OIL}}
  ├─ CURRENT: {{REMAINING:-14 TINS REMAINING}}
  ├─ MIN THRESHOLD: 30 TINS
  └─► REORDER STATUS: PLACED
  ───── ༓ ─────
✦ LEAD TIME: 48 HOURS
✦ SUPPLIER: VALE ESTATE
SUPPLIER PO: {{PO_NUMBER:-PO-88219}}
""",
            description: "Automated warehouse inventory threshold depletion alarm.",
            tags: ["inventory", "stock", "warehouse", "reorder"]
        ),
        
        SignalPostPreset(
            id: "shift_handover",
            title: "Watch Operations Handover",
            category: "Logistics & Dispatch",
            rawContent: """
       ꧁ ༺ ♔ ༻ ꧂
  ╔══════════════════╗
  ║    𝔚𝔄𝔗ℭℌ  ℒ𝔒𝔊    ║
  ╚══════════════════╝
◈ WATCH: {{SHIFT:-NIGHT WATCH (00-08)}}
◈ COMMANDER: {{COMMANDER:-@OFFICER_4}}
◈ INCIDENTS: 0 CRITICAL
  ├─ DISPATCHES: 14 RUNS
  ├─ PARCELS SIGNED: 38
  └─► NETWORK HEALTH: 100%
  ~ ~ ~ ❦ ~ ~ ~
HANDOVER TO: {{NEXT_SHIFT:-@MORNING_WATCH}}
SYSTEM TIME: {{TIMESTAMP:-08:00}}
       ꧁ ༺ ♔ ༻ ꧂
""",
            description: "End-of-shift operational handover briefing and parcel audit.",
            tags: ["handover", "shift", "operations", "logistics"]
        )
    ]
    
    /// Helper to find a preset by identifier
    public static func preset(for id: String) -> SignalPostPreset? {
        return allPresets.first { $0.id == id }
    }
    
    /// Categories available across all presets
    public static var categories: [String] {
        var set: [String] = []
        for p in allPresets {
            if !set.contains(p.category) {
                set.append(p.category)
            }
        }
        return set
    }
}
