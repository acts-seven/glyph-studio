import SwiftUI

@main
struct GLYPHApp: App {
    var body: some Scene {
        WindowGroup {
            SplitStudioView()
        }
        #if os(macOS)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        #endif
    }
}
