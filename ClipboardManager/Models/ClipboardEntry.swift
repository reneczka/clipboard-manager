import Foundation
import AppKit

struct ClipboardEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let timestamp: Date
    let dataType: ClipboardDataType
    let text: String?
    let imageData: Data?
    let htmlData: Data?
    let rtfData: Data?
    let url: URL?
    
    init(id: UUID = UUID(),
         timestamp: Date = Date(),
         dataType: ClipboardDataType,
         text: String? = nil,
         imageData: Data? = nil,
         htmlData: Data? = nil,
         rtfData: Data? = nil,
         url: URL? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.dataType = dataType
        self.text = text
        self.imageData = imageData
        self.htmlData = htmlData
        self.rtfData = rtfData
        self.url = url
    }
    
    // Implement Equatable
    static func == (lhs: ClipboardEntry, rhs: ClipboardEntry) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Helper method to get display text
    var displayText: String {
        switch dataType {
        case .text:
            return text ?? "Empty text"
        case .image:
            return "Image"
        case .url:
            return url?.absoluteString ?? "Invalid URL"
        case .html:
            return "HTML content"
        case .rtf:
            return "Rich text"
        }
    }
} 
