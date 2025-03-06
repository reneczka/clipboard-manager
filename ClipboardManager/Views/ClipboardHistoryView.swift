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
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.text)
                                .lineLimit(2)
                                .padding(.top, 4)
                            HStack {
                                Text(entry.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if lastCopiedId == entry.id {
                                    Text("Copied!")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                        }
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
                            clipboardManager.copyToClipboard(text: entry.text)
                            lastCopiedId = entry.id
                            
                            // Reset the "Copied!" indicator after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                if lastCopiedId == entry.id {
                                    lastCopiedId = nil
                                }
                            }
                        }
                        .contextMenu {
                            Button("Copy") {
                                clipboardManager.copyToClipboard(text: entry.text)
                                lastCopiedId = entry.id
                                
                                // Reset the "Copied!" indicator after 2 seconds
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
