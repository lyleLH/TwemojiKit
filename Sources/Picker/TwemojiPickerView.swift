//
//  TwemojiPickerView.swift
//  TwemojiKit
//
//  Created by Claude on 2026-03-13.
//

import SwiftUI
import UIKit

// MARK: - Twemoji Picker View

/// A customizable emoji picker that displays twemoji images organized by sections.
///
/// Layout (matching reference style):
/// - Top: horizontal category tab bar with twemoji icons
/// - Bottom: vertical scrolling emoji grid (6 columns)
///
/// Usage:
/// ```swift
/// TwemojiPickerView(
///     sections: [
///         recentStore.section(title: "Recently Used"),
///         TwemojiPickerSection(title: "Popular", emojis: ["😀", "❤️", "👍"]),
///     ],
///     onSelect: { emoji in recentStore.record(emoji) }
/// )
/// ```
@available(iOS 14.0, *)
public struct TwemojiPickerView: View {
    private let sections: [TwemojiPickerSection]
    private let columns: Int
    private let recentTitle: String
    private let onSelect: (String) -> Void

    @State private var selectedSectionIndex: Int
    @State private var recentEmojis: [String]

    /// Creates a picker with custom sections and an optional "recent" section.
    ///
    /// - Parameters:
    ///   - sections: The emoji sections to display.
    ///   - recentEmojis: Emojis to show in the "Recent" tab (pass from outside, e.g. UserDefaults).
    ///   - recentTitle: Title for the recent section. Defaults to "Recent".
    ///   - columns: Number of grid columns. Defaults to 6.
    ///   - initialSection: Index into the *all* sections (recent + custom) to show first.
    ///   - onSelect: Called when an emoji is tapped. The caller is responsible for persisting recent emojis.
    public init(
        sections: [TwemojiPickerSection],
        recentEmojis: [String] = [],
        recentTitle: String = TwemojiL10n("twemoji.recent"),
        columns: Int = 6,
        initialSection: Int? = nil,
        onSelect: @escaping (String) -> Void
    ) {
        self.sections = sections
        self.columns = columns
        self.recentTitle = recentTitle
        self.onSelect = onSelect
        _recentEmojis = State(initialValue: recentEmojis)

        // Build all sections to determine default index
        let hasRecent = !recentEmojis.isEmpty
        let allVisible = (hasRecent ? 1 : 0) + sections.filter({ !$0.emojis.isEmpty }).count
        let defaultIndex: Int
        if let initial = initialSection {
            defaultIndex = min(initial, max(allVisible - 1, 0))
        } else {
            // If recent is empty, start at first custom section (index 0 since recent is hidden)
            defaultIndex = 0
        }
        _selectedSectionIndex = State(initialValue: defaultIndex)
    }

    /// All sections including recent (if non-empty)
    private var allSections: [TwemojiPickerSection] {
        var result = [TwemojiPickerSection]()
        if !recentEmojis.isEmpty {
            result.append(TwemojiPickerSection(id: "_recent", title: recentTitle, emojis: recentEmojis))
        }
        result.append(contentsOf: sections.filter { !$0.emojis.isEmpty })
        return result
    }

    private var currentSection: TwemojiPickerSection? {
        guard selectedSectionIndex < allSections.count else { return nil }
        return allSections[selectedSectionIndex]
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Category tab bar
            if allSections.count > 1 {
                categoryTabBar
                Divider()
            }

            // Emoji grid
            if let section = currentSection {
                emojiGrid(section)
            }
        }
        .background(Color(.systemBackground))
        .onChange(of: allSections.count) { _ in
            if selectedSectionIndex >= allSections.count {
                selectedSectionIndex = max(0, allSections.count - 1)
            }
        }
    }

    // MARK: - Category Tab Bar

    private var categoryTabBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(allSections.enumerated()), id: \.offset) { index, section in
                        categoryTab(section: section, index: index)
                            .id(index)
                    }
                }
                .padding(.horizontal, 4)
            }
            .background(Color(.systemBackground))
            .onChange(of: selectedSectionIndex) { newIndex in
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
        .frame(height: 64)
    }

    private func categoryTab(section: TwemojiPickerSection, index: Int) -> some View {
        let isSelected = index == selectedSectionIndex
        let icon = section.emojis.first ?? "❓"

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedSectionIndex = index
            }
        } label: {
            VStack(spacing: 2) {
                TwemojiCellView(emoji: icon, size: 28)

                Text(section.title)
                    .font(.system(size: 10))
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .accentColor : Color(.secondaryLabel))
                    .lineLimit(1)

                // Selected indicator
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .frame(width: 16, height: 3)
            }
            .frame(width: 72, height: 60)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Emoji Grid

    private func emojiGrid(_ section: TwemojiPickerSection) -> some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: columns),
                spacing: 4
            ) {
                ForEach(Array(section.emojis.enumerated()), id: \.offset) { _, emoji in
                    Button {
                        addToRecent(emoji)
                        onSelect(emoji)
                    } label: {
                        emojiCell(emoji)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }

    private func addToRecent(_ emoji: String) {
        var updated = recentEmojis
        updated.removeAll { $0 == emoji }
        updated.insert(emoji, at: 0)
        if updated.count > 30 {
            updated = Array(updated.prefix(30))
        }
        recentEmojis = updated
    }

    private func emojiCell(_ emoji: String) -> some View {
        let cellSize = (UIScreen.main.bounds.width - 24 - CGFloat(columns - 1) * 4) / CGFloat(columns)

        return TwemojiCellView(emoji: emoji, size: cellSize - 8)
            .frame(width: cellSize, height: cellSize)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(8)
    }
}

// MARK: - Twemoji Cell View

@available(iOS 14.0, *)
public struct TwemojiCellView: View {
    public let emoji: String
    public let size: CGFloat

    @StateObject private var loader = TwemojiImageLoader()

    public init(emoji: String, size: CGFloat) {
        self.emoji = emoji
        self.size = size
    }

    public var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
            } else {
                Text(emoji)
                    .font(.system(size: size * 0.7))
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            loader.load(emoji: emoji)
        }
        .onChange(of: emoji) { newEmoji in
            loader.load(emoji: newEmoji)
        }
    }
}

// MARK: - Image Loader

@available(iOS 13.0, *)
final class TwemojiImageLoader: ObservableObject {
    @Published var image: UIImage?

    private static let cache = NSCache<NSString, UIImage>()
    private static let parser = Twemoji()
    private var task: URLSessionDataTask?

    func load(emoji: String) {
        let cacheKey = emoji as NSString
        if let cached = Self.cache.object(forKey: cacheKey) {
            self.image = cached
            return
        }

        guard let url = Self.parser.parse(emoji).first?.imageURL else { return }

        task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let uiImage = UIImage(data: data) else { return }
            Self.cache.setObject(uiImage, forKey: cacheKey)
            DispatchQueue.main.async {
                self?.image = uiImage
            }
        }
        task?.resume()
    }

    deinit {
        task?.cancel()
    }
}
