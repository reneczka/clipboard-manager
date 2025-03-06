import Foundation

struct ClipboardEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let timestamp: Date
    
    init(id: UUID = UUID(), text: String, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
    }
    
    // Implement Equatable
    static func == (lhs: ClipboardEntry, rhs: ClipboardEntry) -> Bool {
        return lhs.id == rhs.id
    }
}
