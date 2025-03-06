import SwiftUI

@main
struct ClipboardManagerApp: App {
    var body: some Scene {
        MenuBarExtra("Clipboard Manager", systemImage: "clipboard") {
            ClipboardHistoryView()
        }
        .menuBarExtraStyle(.window)
    }
}
