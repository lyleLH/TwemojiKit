//
//  UIImage+Twemoji.swift
//  TwemojiKit
//
//  Created by hao92 on 2024-12-16.
//

import UIKit
import TwemojiKit
import SVGKit
import SDWebImage

private actor TwemojiTaskManager {
    static let shared = TwemojiTaskManager()
    private var loadingTasks: [String: Task<UIImage, Error>] = [:]
    private var failedKeys = Set<String>()
    
    func getExistingTask(for emoji: String) -> Task<UIImage, Error>? {
        return loadingTasks[emoji]
    }
    
    func storeTask(_ task: Task<UIImage, Error>, for emoji: String) {
        loadingTasks[emoji] = task
    }
    
    func removeTask(for emoji: String) {
        loadingTasks.removeValue(forKey: emoji)
    }
    
    func markAsFailed(_ key: String) {
        failedKeys.insert(key)
    }
    
    func shouldRetry(_ key: String) -> Bool {
        return failedKeys.remove(key) != nil
    }
}

public extension UIImage {
    private static let cacheFolderName = "TwemojiCache"
    private static let standardSize = CGSize(width: 512, height: 512)
    private static let thumbnailSize = CGSize(width: 64, height: 64)
    
    private static func getCacheKey(emoji: String, isStandard: Bool) -> String {
        // 获取emoji的Unicode码点
        let unicodeScalars = emoji.unicodeScalars.map { String(format: "%04X", $0.value) }.joined()
        let suffix = isStandard ? "_standard" : "_thumbnail"
        return "twemoji_\(unicodeScalars)\(suffix)"
    }
    
    @MainActor
    static func loadTwEmoji(emoji: String, size: CGSize, forThumbnail: Bool = false) async throws -> UIImage {
        let targetSize = forThumbnail ? thumbnailSize : standardSize
        let cacheKey = getCacheKey(emoji: emoji, isStandard: !forThumbnail)
        
        // 检查是否需要重试
        let shouldRetry = await TwemojiTaskManager.shared.shouldRetry(cacheKey)
        
        // 如果不需要重试，尝试从缓存加载
        if !shouldRetry {
            // 检查是否已经有相同的加载任务
            if let existingTask = await TwemojiTaskManager.shared.getExistingTask(for: cacheKey) {
                let image = try await existingTask.value
                return image.resize(targetSize: size)
            }
            
            // 尝试从SDWebImage缓存加载
            if let cachedImage = SDImageCache.shared.imageFromCache(forKey: cacheKey) {
                return cachedImage.resize(targetSize: size)
            }
        }
        
        // 创建新的加载任务
        let task = Task<UIImage, Error> { @MainActor in
            do {
                // 如果缓存中没有，则从网络加载
                let twemoji = Twemoji()
                guard let originalURL = twemoji.parse(emoji).first?.imageURL,
                      var urlComponents = URLComponents(url: originalURL, resolvingAgainstBaseURL: true) else {
                    await TwemojiTaskManager.shared.markAsFailed(cacheKey)
                    return createEmojiImage(from: emoji, size: size)
                }
                
                // 修改 URL 以使用 SVG 路径
                urlComponents.scheme = "https"
                urlComponents.host = "cdn.jsdelivr.net"
                urlComponents.path = urlComponents.path
                    .replacingOccurrences(of: "/72x72/", with: "/svg/")
                    .replacingOccurrences(of: ".png", with: ".svg")
                
                guard let url = urlComponents.url else {
                    await TwemojiTaskManager.shared.markAsFailed(cacheKey)
                    return createEmojiImage(from: emoji, size: size)
                }
                
                // 使用 SDWebImage 下载 SVG 数据
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // 创建SVG源
                let source = SVGKSourceNSData.source(from: data, urlForRelativeLinks: url)
                guard let svgImage = SVGKImage(source: source) else {
                    await TwemojiTaskManager.shared.markAsFailed(cacheKey)
                    return createEmojiImage(from: emoji, size: size)
                }
                
                // 设置SVG图像的尺寸
                svgImage.size = targetSize
                
                // 获取UIImage并缓存
                guard let image = svgImage.uiImage else {
                    await TwemojiTaskManager.shared.markAsFailed(cacheKey)
                    return createEmojiImage(from: emoji, size: size)
                }
                
                // 使用 SDWebImage 缓存图片，但使用自定义的缓存键来避免 PNG 解码问题
                let cacheKey = "svg_\(getCacheKey(emoji: emoji, isStandard: !forThumbnail))"
                SDImageCache.shared.store(image, forKey: cacheKey, completion: nil)
                
                // 如果是标准尺寸，同时生成并缓存缩略图
                if !forThumbnail {
                    let thumbnailKey = "svg_\(getCacheKey(emoji: emoji, isStandard: false))"
                    svgImage.size = thumbnailSize
                    if let thumbnailImage = svgImage.uiImage {
                        SDImageCache.shared.store(thumbnailImage, forKey: thumbnailKey, completion: nil)
                    }
                }
                
                return image.resize(targetSize: size)
            } catch {
                await TwemojiTaskManager.shared.markAsFailed(cacheKey)
                return createEmojiImage(from: emoji, size: size)
            }
        }
        
        // 保存任务引用
        await TwemojiTaskManager.shared.storeTask(task, for: cacheKey)
        
        do {
            let result = try await task.value
            await TwemojiTaskManager.shared.removeTask(for: cacheKey)
            return result
        } catch {
            await TwemojiTaskManager.shared.removeTask(for: cacheKey)
            throw error
        }
    }
    
    @MainActor private static func createEmojiImage(from emoji: String, size: CGSize) -> UIImage {
        let label = UILabel(frame: CGRect(origin: .zero, size: size))
        label.font = .systemFont(ofSize: min(size.width, size.height) * 0.8)
        label.text = emoji
        label.textAlignment = .center
        label.backgroundColor = .clear
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext() {
            label.layer.render(in: context)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                return image
            }
        }
        
        // 如果转换失败，返回一个空白图片
        return UIImage()
    }
}
extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
}
