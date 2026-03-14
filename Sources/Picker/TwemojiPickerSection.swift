//
//  TwemojiPickerSection.swift
//  TwemojiKit
//
//  Created by Claude on 2026-03-13.
//

import Foundation

/// A section of emojis displayed in the picker.
///
/// Usage:
/// ```swift
/// let popular = TwemojiPickerSection(title: "Popular", emojis: ["😀", "❤️", "👍"])
/// let animals = TwemojiPickerSection(title: "Animals", emojis: ["🐶", "🐱", "🐭"])
/// ```
public struct TwemojiPickerSection: Identifiable {
    public let id: String
    public let title: String
    public let emojis: [String]

    public init(title: String, emojis: [String]) {
        self.id = title
        self.title = title
        self.emojis = emojis
    }

    public init(id: String, title: String, emojis: [String]) {
        self.id = id
        self.title = title
        self.emojis = emojis
    }
}
