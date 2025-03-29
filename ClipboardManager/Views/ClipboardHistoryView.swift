import SwiftUI

struct ClipboardHistoryView: View {
    @StateObject private var clipboardManager = ClipboardHistoryManager()
    @State private var hoveredItemId: UUID?
    @State private var lastCopiedId: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(clipboardManager.clipboardHistory) { entry in
                        ClipboardEntryView(entry: entry, isCopied: entry.id == lastCopiedId)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(hoveredItemId == entry.id ?
                                         Color(NSColor.selectedControlColor) :
                                         Color(NSColor.controlBackgroundColor))
                            )
                            .onHover { isHovered in
                                hoveredItemId = isHovered ? entry.id : nil
                            }
                            .onTapGesture {
                                clipboardManager.copyToClipboard(entry)
                                lastCopiedId = entry.id
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    if lastCopiedId == entry.id {
                                        lastCopiedId = nil
                                    }
                                }
                            }
                            .contextMenu {
                                Button("Copy") {
                                    clipboardManager.copyToClipboard(entry)
                                    lastCopiedId = entry.id
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        if lastCopiedId == entry.id {
                                            lastCopiedId = nil
                                        }
                                    }
                                }
                            }
                    }
                }
                .padding(.vertical, 8)
            }
            
            Divider()
            
            Button("Clear History") {
                clipboardManager.clearHistory()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 300, height: 400)
        .onAppear {
            clipboardManager.loadHistory()
        }
    }
}

struct ClipboardEntryView: View {
    let entry: ClipboardEntry
    let isCopied: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                typeIcon
                    .frame(width: 16, height: 16)
                    .foregroundColor(.secondary)
                
                contentView
            }
            
            HStack {
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isCopied {
                    Text("Copied!")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    @ViewBuilder
    private var typeIcon: some View {
        switch entry.dataType {
        case .text, .rtf:
            Image(systemName: "doc.text")
        case .url:
            Image(systemName: "link")
        case .html:
            Image(systemName: "chevron.left.forwardslash.chevron.right")
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch entry.dataType {
        case .text:
            Text(entry.text ?? "")
                .lineLimit(2)
        case .url:
            if let url = entry.url {
                Link(url.absoluteString, destination: url)
                    .lineLimit(2)
                    .foregroundColor(.blue)
            }
        case .html:
            HStack {
                Text("HTML Content")
                    .foregroundColor(.secondary)
                if let htmlData = entry.htmlData,
                   let preview = String(data: htmlData, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines) {
                    Text(preview)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
            }
        case .rtf:
            if let rtfData = entry.rtfData,
               let attributedString = try? NSAttributedString(data: rtfData, 
                                                            options: [.documentType: NSAttributedString.DocumentType.rtf],
                                                            documentAttributes: nil) {
                Text(AttributedString(attributedString))
                    .lineLimit(2)
                    .textSelection(.enabled)
            } else {
                Text("Rich Text Content")
                    .foregroundColor(.secondary)
            }
        }
    }
}
