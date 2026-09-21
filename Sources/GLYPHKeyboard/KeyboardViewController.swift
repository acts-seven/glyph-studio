import UIKit
import GLYPHCore

public class KeyboardViewController: UIInputViewController {
    
    private var activeStyle: TypographyStyle = .frakturBold
    private var stackView: UIStackView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)
        
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        // 1. Top Style Selector Bar
        let styleScroll = UIScrollView()
        styleScroll.showsHorizontalScrollIndicator = false
        let styleRow = UIStackView()
        styleRow.axis = .horizontal
        styleRow.spacing = 6
        styleRow.translatesAutoresizingMaskIntoConstraints = false
        styleScroll.addSubview(styleRow)
        
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
            btn.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            btn.layer.cornerRadius = 6
            btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
            btn.addAction(UIAction { [weak self] _ in
                self?.activeStyle = style
            }, for: .touchUpInside)
            styleRow.addArrangedSubview(btn)
        }
        
        container.addArrangedSubview(styleScroll)
        
        // 2. Quick Symbols & Swirls
        let quickRow = UIStackView()
        quickRow.axis = .horizontal
        quickRow.spacing = 6
        quickRow.distribution = .fillEqually
        
        let quickGlyphs = ["𓆩 ⚡︎ 𓆪", "𓆩 𖤍 𓆪", "░▒▓█", "╍ ❖ ╍", "༺ ༓ ༻", "⏣ ⎔ ⏣", "◈", "➔"]
        for glyph in quickGlyphs {
            let btn = UIButton(type: .system)
            btn.setTitle(glyph, for: .normal)
            btn.setTitleColor(.cyan, for: .normal)
            btn.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
            btn.layer.cornerRadius = 6
            btn.addAction(UIAction { [weak self] _ in
                self?.textDocumentProxy.insertText(glyph + " ")
            }, for: .touchUpInside)
            quickRow.addArrangedSubview(btn)
        }
        container.addArrangedSubview(quickRow)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            container.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -8),
            
            styleRow.topAnchor.constraint(equalTo: styleScroll.topAnchor),
            styleRow.leadingAnchor.constraint(equalTo: styleScroll.leadingAnchor),
            styleRow.trailingAnchor.constraint(equalTo: styleScroll.trailingAnchor),
            styleRow.bottomAnchor.constraint(equalTo: styleScroll.bottomAnchor),
            styleRow.heightAnchor.constraint(equalTo: styleScroll.heightAnchor),
            styleScroll.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
}
