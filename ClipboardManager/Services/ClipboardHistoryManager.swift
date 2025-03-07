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
        
        print("Available types:", pasteboard.types ?? [])
        
        // Get all available types
        let types = pasteboard.types ?? []
        
        // Debug HTML types
        print("Checking HTML:")
        print("Has .html:", types.contains(.html))
        print("Has public.html:", types.contains(NSPasteboard.PasteboardType("public.html")))
        print("Has Apple web archive:", types.contains(NSPasteboard.PasteboardType("Apple Web Archive pasteboard type")))
        
        // Check if it's HTML content (Chrome and Safari support)
        if types.contains(.string) {
            // Chrome often includes HTML in the string type
            if let string = pasteboard.string(forType: .string),
               string.contains("<") && string.contains(">") {
                print("Found HTML in string type")
                addEntry(ClipboardEntry(dataType: .html, htmlData: string.data(using: .utf8)))
                return
            }
        }
        
        // Standard HTML types
        if let htmlData = pasteboard.data(forType: .html) {
            print("Found standard HTML data")
            addEntry(ClipboardEntry(dataType: .html, htmlData: htmlData))
            return
        }
        
        if let htmlData = pasteboard.data(forType: NSPasteboard.PasteboardType("public.html")) {
            print("Found public HTML data")
            addEntry(ClipboardEntry(dataType: .html, htmlData: htmlData))
            return
        }
        
        if let htmlData = pasteboard.data(forType: NSPasteboard.PasteboardType("Apple Web Archive pasteboard type")) {
            print("Found Safari web archive data")
            addEntry(ClipboardEntry(dataType: .html, htmlData: htmlData))
            return
        }
        
        // Check if it's a URL (Chrome might use string type for URLs)
        if types.contains(.URL) || (types.contains(.string) && isURL(pasteboard.string(forType: .string))) {
            if let urlString = pasteboard.string(forType: .URL) ?? pasteboard.string(forType: .string),
               let url = URL(string: urlString) {
                print("Detected URL:", url)
                addEntry(ClipboardEntry(dataType: .url, url: url))
                return
            }
        }
        
        // Debug RTF
        print("Checking RTF:")
        print("Has .rtf:", types.contains(.rtf))
        if let rtfData = pasteboard.data(forType: .rtf) {
            print("Found RTF data of size:", rtfData.count)
            addEntry(ClipboardEntry(dataType: .rtf, rtfData: rtfData))
            return
        }
        
        // Handle other types
        if let string = pasteboard.string(forType: .string) {
            print("Detected text:", string)
            addEntry(ClipboardEntry(dataType: .text, text: string))
        } else if let image = pasteboard.data(forType: .tiff) ?? pasteboard.data(forType: .png) {
            print("Detected image")
            addEntry(ClipboardEntry(dataType: .image, imageData: image))
        }
    }
    
    // Helper function to check if a string is a URL
    private func isURL(_ string: String?) -> Bool {
        guard let string = string else { return false }
        return string.lowercased().hasPrefix("http://") ||
               string.lowercased().hasPrefix("https://") ||
               string.lowercased().hasPrefix("www.")
    }
    
    private func addEntry(_ entry: ClipboardEntry) {
        // Don't add if it's the same as the most recent entry
        if let lastEntry = clipboardHistory.first {
            switch (entry.dataType, lastEntry.dataType) {
            case (.text, .text):
                if entry.text == lastEntry.text { return }
            case (.url, .url):
                if entry.url == lastEntry.url { return }
            case (.image, .image):
                if entry.imageData == lastEntry.imageData { return }
            case (.html, .html):
                if entry.htmlData == lastEntry.htmlData { return }
            case (.rtf, .rtf):
                if entry.rtfData == lastEntry.rtfData { return }
            default:
                break
            }
        }
        
        clipboardHistory.insert(entry, at: 0)
        
        if clipboardHistory.count > maxEntries {
            clipboardHistory.removeLast()
        }
        
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
    
    func copyToClipboard(_ entry: ClipboardEntry) {
        pasteboard.clearContents()
        
        switch entry.dataType {
        case .text:
            if let text = entry.text {
                pasteboard.setString(text, forType: .string)
            }
        case .url:
            if let url = entry.url {
                pasteboard.setString(url.absoluteString, forType: .string)
                pasteboard.setString(url.absoluteString, forType: .URL)
            }
        case .image:
            if let imageData = entry.imageData {
                pasteboard.setData(imageData, forType: .tiff)
            }
        case .html:
            if let htmlData = entry.htmlData {
                pasteboard.setData(htmlData, forType: .html)
            }
        case .rtf:
            if let rtfData = entry.rtfData {
                pasteboard.setData(rtfData, forType: .rtf)
            }
        }
        
        lastChangeCount = pasteboard.changeCount
    }
}
