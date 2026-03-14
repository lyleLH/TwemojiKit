# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TwemojiKit is an iOS Swift library that parses emoji characters into [Twemoji](https://github.com/jdecked/twemoji) image URLs. It uses the twemoji JavaScript library (via JavaScriptCore) to convert native iOS emoji to their corresponding Twemoji representations.

## Build & Test Commands

```bash
# Build with Swift Package Manager
swift build

# Run tests
swift test

# Build via Xcode (the project also has a .xcodeproj)
xcodebuild -scheme TwemojiKit -sdk iphonesimulator build
```

The package requires iOS 13+ and Swift 5. It is distributed via SPM, CocoaPods, and Carthage.

## Architecture

**Emoji parsing pipeline:** `Twemoji` (the main class) loads `twemoji.min.js` into a `JSContext` at init time. Parsing works in two stages:
1. `parseWithJS` — evaluates the emoji through the JS twemoji library to get the icon code
2. `convertToCode` — fallback that manually converts Unicode scalars to hex codes if JS parsing returns empty

**Key types:**
- `Twemoji` — singleton-style parser (also supports non-shared instances). Entry points: `parse(_:)` returns `[TwemojiImage]`, `parseAttributeString(_:)` returns `NSAttributedString` with embedded twemoji images
- `TwemojiImage` — data struct holding emoji base string, size, code, and computed `imageURL` pointing to jsdelivr CDN (version 15.1.0)
- `TwemojiSize` — enum with `.x72` default and `.custom(String)` for arbitrary sizes
- `UIImage+Twemoji` (in-progress) — async SVG-based loading with `TwemojiTaskManager` actor for deduplication, SDWebImage caching, and SVGKit rendering. Falls back to rendering native emoji via UILabel if network/SVG fails

**Dependencies:** SVGKit (SVG rendering), SDWebImage (image caching). The JS core (`Sources/Core/twemoji.min.js`) is bundled as a SPM resource.

**Extension files** in `Sources/Extensions/`:
- `String+Extension` — `Character.isEmoji` / `String.containsEmoji` detection used by the parser
- `JSContext+Extension` — subscript helpers for JSContext key access
- `UIImage+Extension` — `UIImage(url:)` synchronous init, image resize, and `UIImageView.loadTwemoji` async loader

## Important Notes

- `UIImage+Twemoji.swift` imports `TwemojiKit` as an external module (not part of the library target) — it's an extension file intended for app-level use
- The `Twemoji.shared` singleton referenced in tests and README uses a pattern from before the current `public init()` — tests use `Twemoji.shared` but the current source only has `public init()`
- Twemoji image URLs follow the pattern: `https://cdn.jsdelivr.net/gh/jdecked/twemoji@15.1.0/assets/{size}/{code}.png`
