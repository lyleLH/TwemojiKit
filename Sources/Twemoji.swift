//
//  Twemoji.swift
//  TwemojiKit
//
//  Created by yochidros on 2020/04/23.
//  Copyright © 2020 yochidros. All rights reserved.
//

import Foundation
import JavaScriptCore
import UIKit

private let TwemojiCoreName = "twemoji.min"
private let TwemojiCoreExt = ".js"
private let bundleIdentifier = "com.yochidros.TwemojiKit"

public class Twemoji {
    private let context = JSContext(virtualMachine: JSVirtualMachine())
    private typealias ConvertedType = (base: String, code: String)

    public static let shared = Twemoji()
    public private(set) var isAvailable: Bool = false
    private let bundle: Bundle?

    public init() {
        #if SWIFT_PACKAGE
        self.bundle = Bundle.module
        #else
        self.bundle = Bundle(identifier: bundleIdentifier)
        #endif
        prepare()
    }

    private func prepare() {
        let jsFilePath = bundle?.path(forResource: TwemojiCoreName, ofType: TwemojiCoreExt)
        if let filePath = jsFilePath {
            let expandedPath = NSString(string: filePath).expandingTildeInPath
            guard let coreContent = try? String(contentsOfFile: expandedPath) else { return }
            context?.evaluateScript(coreContent)
            context?.evaluateScript("var twemoji = require('twemoji');")
            isAvailable = true
        } else {
            isAvailable = false
        }
    }

    public func parse(_ str: String) -> [TwemojiImage] {
        guard str.containsEmoji, test(str: str) else { return [] }
        var converted = parseWithJS(str: str)
        guard !converted.isEmpty else {
            converted = convertToCode(str: str)
            return converted.map { TwemojiImage(base: $0.base, size: .default, code: $0.code) }
        }
        return converted.map { TwemojiImage(base: $0.base, size: .default, code: $0.code) }
    }

    public func parseAttributeString(_ str: String, size: Int = TwemojiSize.default.size, attributes attrs: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: str, attributes: attrs)
        let emojiImages = parse(str)

        // Collect all ranges first, then replace from end to start to preserve positions
        var replacements: [(nsRange: NSRange, attachment: NSTextAttachment)] = []
        var searchStartIndex = attrString.string.startIndex

        for image in emojiImages {
            if let range = attrString.string[searchStartIndex...].range(of: image.base), let url = image.imageURL {
                let nsRange = NSRange(range, in: attrString.string)
                searchStartIndex = range.upperBound
                let attachment = NSTextAttachment()
                attachment.image = UIImage(url: url).resize(size: CGSize(width: size, height: size))
                attachment.bounds = CGRect(x: 0, y: -2, width: CGFloat(size), height: CGFloat(size))
                replacements.append((nsRange: nsRange, attachment: attachment))
            }
        }

        for replacement in replacements.reversed() {
            attrString.replaceCharacters(in: replacement.nsRange, with: NSAttributedString(attachment: replacement.attachment))
        }

        if let attrs = attrs {
            attrString.addAttributes(attrs, range: NSRange(location: 0, length: attrString.length))
        }
        return NSAttributedString(attributedString: attrString)
    }

    @available(*, deprecated, message: "This is deprecated, Use downloadImage instead")
    public func convertImage(twemoji: TwemojiImage) -> UIImage? {
        guard let url = twemoji.imageURL else { return nil }
        return UIImage(url: url)
    }

    public func downloadImage(twemoji: TwemojiImage, into imageView: UIImageView) {
        imageView.loadTwemoji(twemojiUrl: twemoji.imageURL)
    }
}

// MARK: Private Methods

extension Twemoji {
    private func convertToCode(str: String) -> [ConvertedType] {
        let emojis = str.emojis.map { String($0) }
        guard !emojis.isEmpty else { return [] }
        var result = [ConvertedType]()
        for value in emojis {
            let code = value.unicodeScalars
                .map { String(format: "%x", $0.value) }
                .joined(separator: "-")
            if !code.isEmpty {
                let converted: ConvertedType = (base: value, code: code)
                result.append(converted)
            }
        }
        return result
    }

    private func escapeForJS(_ str: String) -> String {
        return str
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
    }

    private func parseWithJS(str: String) -> [ConvertedType] {
        var result = [ConvertedType]()
        str.emojis.map { String($0) }.forEach { emoji in
            let escaped = escapeForJS(emoji)
            context?.evaluateScript("""
            var iconCode = "";
            var twemojiCode = twemoji.parse('\(escaped)', {
                callback: function(iconId, options) {
                    iconCode = iconId;
                    return '';
                }
            });
            """)
            if let code = context?["iconCode"]?.toString(), !code.isEmpty {
                let converted: ConvertedType = (base: emoji, code: code)
                result.append(converted)
            }
        }
        return result
    }

    private func test(str: String) -> Bool {
        let escaped = escapeForJS(str)
        context?.evaluateScript("var result = twemoji.test('\(escaped)');")
        guard let result = context?.objectForKeyedSubscript("result")?.toBool() else { return false }
        return result
    }
}
