import SwiftUI
import GLYPHCore

public struct SplitStudioView: View {
    @State private var state = AppState()
    
    public init() {}
    
    public var body: some View {
        Group {
            #if os(macOS)
            HSplitView {
                ComposerPane(state: state)
                    .frame(minWidth: 360)
                
                SignalMirrorPane(state: state)
                    .frame(minWidth: 360)
            }
            .frame(minWidth: 760, minHeight: 520)
            #else
            ViewThatFits {
                HStack(spacing: 0) {
                    ComposerPane(state: state)
                    Divider()
                    SignalMirrorPane(state: state)
                }
                VStack(spacing: 0) {
                    ComposerPane(state: state)
                    Divider()
                    SignalMirrorPane(state: state)
                }
            }
            #endif
        }
        .overlay(alignment: .top) {
            if state.showCopiedBanner {
                Text("Copied for Signal with Zero-Wrap Guarantee!")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.85))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.green, lineWidth: 1))
                    .shadow(radius: 8)
                    .padding(.top, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
