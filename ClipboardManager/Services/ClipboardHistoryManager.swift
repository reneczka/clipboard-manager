import Foundation
import AppKit

class ClipboardHistoryManager: ObservableObject {
    @Published private(set) var clipboardHistory: [ClipboardEntry] = []
    private let maxEntries = 10
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    
    init() {
        lastChangeCount = pasteboard.changeCount
        startMonitoring()
    }
    
    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }
    
    private func checkForChanges() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        
        if let text = pasteboard.string(forType: .string) {
            addEntry(text: text)
        }
    }
    
    private func addEntry(text: String) {
        // Don't add if it's the same as the most recent entry
        if let lastEntry = clipboardHistory.first, lastEntry.text == text {
            return
        }
        
        let newEntry = ClipboardEntry(text: text)
        clipboardHistory.insert(newEntry, at: 0)
        
        // Keep only the last 10 entries
        if clipboardHistory.count > maxEntries {
            clipboardHistory.removeLast()
        }
        
        // Save to persistent storage
        saveHistory()
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(clipboardHistory) {
            UserDefaults.standard.set(encoded, forKey: "clipboardHistory")
        }
    }
    
    func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: "clipboardHistory"),
              let decoded = try? JSONDecoder().decode([ClipboardEntry].self, from: data) else {
            return
        }
        clipboardHistory = decoded
    }
    
    func clearHistory() {
        clipboardHistory.removeAll()
        saveHistory()
    }
    
    func copyToClipboard(text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        // Update lastChangeCount to prevent the timer from re-adding this copy
        lastChangeCount = NSPasteboard.general.changeCount
    }
} 
