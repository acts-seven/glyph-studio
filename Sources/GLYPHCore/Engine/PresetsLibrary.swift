import Foundation

public struct SignalPostPreset: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let category: String
    public let rawContent: String
    
    public init(id: String, title: String, category: String, rawContent: String) {
        self.id = id
        self.title = title
        self.category = category
        self.rawContent = rawContent
    }
}

public struct PresetsLibrary: Sendable {
    public static let allPresets: [SignalPostPreset] = [
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
  ┃ ➔ $165.00
  ╍╍╍╍╍ ❖ ╍╍╍╍╍

◈ JASMINE RICE A-GRADE
  ┠ 1 kg Bag (x10)
  ┃ ➔ $28.00 [$2.80/u]
  ┠ 5 kg Bag (x4)
  ┃ ➔ $44.00 [$11/u]
  ┠ 25 kg Sack (x1)
  ┃ ➔ $42.50
  ╍╍╍╍╍ ❖ ╍╍╍╍╍

◈ ALL-PURPOSE FLOUR
  ┠ 1 kg Bag (x12)
  ┃ ➔ $21.60 [$1.80/u]
  ┠ 12.5 kg Bag (x2)
  ┃ ➔ $32.00 [$16/u]
  ┠ 25 kg Sack (x1)
  ┃ ➔ $27.50

      ░▒▓█ 𖤍 █▓▒░
    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
"""
        ),
        SignalPostPreset(
            id: "flash_drop",
            title: "Flash Drop Alert",
            category: "Wholesale & Merchant",
            rawContent: """
       𓆩 ⚡︎ 𓆪
╭━━━━━━━━━━━━━━━━━━━━╮
┃ 𝔉𝔏𝔄𝔖ℌ  𝔇ℜ𝔒𝔓  𝔄𝔏𝔈ℜ𝔗 ┃
╰━━━━━━━━━━━━━━━━━━━━╯
◈ STATUS: LIVE NOW
◈ ALLOCATION: 40 UNITS
◈ CUTOFF: MIDNIGHT
╍╍╍╍╍ ❖ ╍╍╍╍╍
┠ RESERVE: DM @ADMIN
┠ PAYMENT: CASH / USDC
┠ DISPATCH: SAME-DAY
┈┈━═☆═━┈┈
"""
        ),
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
◈ BTC: $64,200 [▲ 2.4%]
◈ ETH: $3,450  [▼ 0.8%]
◈ SOL: $152    [▲ 5.1%]
╍╍╍╍╍ ❖ ╍╍╍╍╍
KEY TAKEAWAYS:
• High volume on majors
• Breakout confirmation
• Tight stops enforced
        ▲   ▲
       ▲ ◈ ▲ ◈ ▲
        ▼   ▼
"""
        ),
        SignalPostPreset(
            id: "syndicate_signals",
            title: "Syndicate Scalp Setup",
            category: "Crypto & Alpha",
            rawContent: """
╭━━━━━━━━━━━━━━━━━━━━╮
┃  𝔖𝔜𝔑𝔇ℑℭ𝔄𝔗𝔈  𝔈𝔑𝔗ℜ𝔜  ┃
╰━━━━━━━━━━━━━━━━━━━━╯
◈ PAIR: SOL / USD
◈ TYPE: LONG SCALP
  ┠ ENTRY: $148 - $151
  ┠ TARGET 1: $158
  ┠ TARGET 2: $166
  ┠ STOP: $144
  ╍╍╍╍╍ ❖ ╍╍╍╍╍
LEVERAGE: 3x - 5x MAX
INVALIDATION: 4H CLOSE
BELOW $143.50
 ░▒▓█ 𖤍 █▓▒░
"""
        ),
        SignalPostPreset(
            id: "vip_access",
            title: "Private Key & Access Pass",
            category: "VIP & Access",
            rawContent: """
░░▒▒▓▓████████████▓▓▒▒░░
▓  ༺  𝔙ℑ𝔓  𝔄ℭℭ𝔈𝔖𝔖  ༻  ▓
░░▒▒▓▓████████████▓▓▒▒░░

◈ PASSPHRASE VERIFIED
◈ TIER: INNER CIRCLE
◈ CLEARANCE: LEVEL 4
╍╍╍╍╍ ❖ ╍╍╍╍╍
  ┠ SESSION: 24 HOURS
  ┠ PROXY: ROTATING
  ┠ ENCRYPTION: E2E
  ┃ ➔ STATUS: ACTIVE
      ░▒▓█ 𖤍 █▓▒░
"""
        ),
        SignalPostPreset(
            id: "nightclub_guestlist",
            title: "Nightclub Guestlist RSVP",
            category: "Events & Luxury",
            rawContent: """
       ꧁ ༺ ♔ ༻ ꧂
  ╔══════════════════╗
  ║    𝔖𝔄𝔑ℭ𝔗𝔘𝔄ℜ𝔜    ║
  ╚══════════════════╝
◈ FRIDAY NIGHT EXCLUSIVE
◈ DOORS: 23:00 SHARP
◈ DRESS: ALL BLACK
╍╍╍╍╍ ❖ ╍╍╍╍╍
  ┠ VIP TABLE 1-4: FULL
  ┠ VIP TABLE 5-8: HOLD
  ┠ MEZZANINE: OPEN
  ┃ ➔ RSVP: @CONCIERGE
       ꧁ ༺ ♔ ༻ ꧂
"""
        ),
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
  ╟── HASHRATE: 3.2 PF
  ╚═▶ [ $4.20/HR ]
⌬ A100 80GB POD
  ╟── LATENCY: 1.4ms
  ╚═▶ [ $1.85/HR ]
╚══════════════════════╝
  ⚡︎ ─ ─ ─ ─ ─ ─ ⚡︎
└───[ ⬡ TERMINATION ⬡ ]───┘
"""
        ),
        SignalPostPreset(
            id: "hermetic_scroll",
            title: "Alchemical Sanctum Manifesto",
            category: "Occult & Sanctum",
            rawContent: """
        ☉ ☽ ☿
╔══════════════════════╗
║   ༺ 𝔒ℭℭ𝔘𝔏𝔗 𝔒ℜ𝔇𝔈ℜ ༻   ║
╚══════════════════════╝
        ᚛ ༒ ᚜

░▒▓ ༒ THE FIRST GATE ༒ ▓▒░

        𓆩 𖤍 𓆪
╭───── ❖ ─────╮
│ TRANSMUTATION │
╰───── ❖ ─────╯
✦ PRINCIPLE OF RHYTHM
  ├─ Everything flows
  └─► As above, so below
✦ PRINCIPLE OF POLARITY
  ├─ Dual nature
  └─► Harmony restored
        ᚛ ༒ ᚜
╚══════════════════════╝
        ☉ ☽ ☿
"""
        )
    ]
}
