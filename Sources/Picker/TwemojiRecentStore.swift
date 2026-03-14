//
//  TwemojiRecentStore.swift
//  TwemojiKit
//
//  Created by Claude on 2026-03-13.
//

import Foundation
import Combine

/// Tracks recently used emojis with automatic persistence via UserDefaults.
///
/// Usage:
/// ```swift
/// let recentStore = TwemojiRecentStore()
///
/// // Record usage (moves to front, deduplicates)
/// recentStore.record("😀")
///
/// // Get a picker section
/// let section = recentStore.section(title: "Recently Used")
/// ```
@available(iOS 13.0, *)
public class TwemojiRecentStore: ObservableObject {
    @Published public private(set) var emojis: [String]

    private let key: String
    private let maxCount: Int
    private let defaults: UserDefaults

    public init(
        key: String = "TwemojiKit.recentEmojis",
        maxCount: Int = 30,
        defaults: UserDefaults = .standard
    ) {
        self.key = key
        self.maxCount = maxCount
        self.defaults = defaults
        self.emojis = defaults.stringArray(forKey: key) ?? []
    }

    /// Records an emoji as recently used. Moves it to the front if already present.
    public func record(_ emoji: String) {
        emojis.removeAll { $0 == emoji }
        emojis.insert(emoji, at: 0)
        if emojis.count > maxCount {
            emojis = Array(emojis.prefix(maxCount))
        }
        defaults.set(emojis, forKey: key)
    }

    /// Returns a `TwemojiPickerSection` containing the recent emojis.
    public func section(title: String = "Recently Used") -> TwemojiPickerSection {
        TwemojiPickerSection(id: "TwemojiRecentStore.\(key)", title: title, emojis: emojis)
    }

    public func clear() {
        emojis = []
        defaults.removeObject(forKey: key)
    }
}
