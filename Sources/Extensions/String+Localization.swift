//
//  String+Localization.swift
//  TwemojiKit
//
//  Created by Claude on 2026-03-13.
//

import Foundation

private class TwemojiKitBundleToken {}

extension Bundle {
    static let twemojiKit: Bundle = {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: TwemojiKitBundleToken.self)
        #endif
    }()

    /// Returns the best matching lproj bundle for the user's preferred language.
    static var twemojiKitLocalized: Bundle {
        let bundle = twemojiKit
        // Find the best matching lproj for the user's preferred languages
        let preferred = Locale.preferredLanguages
        for language in preferred {
            // Try exact match first (e.g. "zh-Hans-CN")
            if let path = bundle.path(forResource: language, ofType: "lproj"),
               let localized = Bundle(path: path) {
                return localized
            }
            // Try language code without region (e.g. "zh-Hans")
            let components = language.split(separator: "-")
            if components.count > 1 {
                // Try "zh-Hans" from "zh-Hans-CN"
                let langCode = components.dropLast().joined(separator: "-")
                if let path = bundle.path(forResource: langCode, ofType: "lproj"),
                   let localized = Bundle(path: path) {
                    return localized
                }
                // Try just the language (e.g. "zh")
                if let path = bundle.path(forResource: String(components[0]), ofType: "lproj"),
                   let localized = Bundle(path: path) {
                    return localized
                }
            }
        }
        // Fallback to English
        if let path = bundle.path(forResource: "en", ofType: "lproj"),
           let localized = Bundle(path: path) {
            return localized
        }
        return bundle
    }
}

/// Shorthand for localizing TwemojiKit strings.
public func TwemojiL10n(_ key: String) -> String {
    return NSLocalizedString(key, bundle: .twemojiKitLocalized, comment: "")
}
