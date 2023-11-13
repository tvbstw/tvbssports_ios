//
//  SKPhoto.swift
//  SKViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit
import Kingfisher
import KingfisherWebP
import CocoaLumberjack

@objc public protocol SKPhotoProtocol: NSObjectProtocol {
    var index: Int { get set }
    var underlyingImage: UIImage! { get }
    var caption: String? { get }
    var contentMode: UIView.ContentMode { get set }
    var photoURL: String! { get }
    func loadUnderlyingImageAndNotify()
    func checkCache()
}

// MARK: - SKPhoto
open class SKPhoto: NSObject, SKPhotoProtocol {
    open var index: Int = 0
    open var underlyingImage: UIImage!
    open var caption: String?
    open var contentMode: UIView.ContentMode = .scaleAspectFill
    open var shouldCachePhotoURLImage: Bool = false
    open var photoURL: String!

    override init() {
        super.init()
    }
    
    convenience init(image: UIImage) {
        self.init()
        underlyingImage = image
    }
    
    convenience init(url: String) {
        self.init()
        photoURL = url
    }
    
    convenience init(url: String, holder: UIImage?) {
        self.init()
        photoURL = url
        underlyingImage = holder
    }
    
    open func checkCache() {
        //修改套件:使用Kingfisher支援Webp格式
        //edit by Eddie 2022/05/06
        let imageCache = KingfisherManager.shared.cache
        let downloader = KingfisherManager.shared.downloader
        
        if imageCache.imageCachedType(forKey: photoURL, processorIdentifier: WebPProcessor.default.identifier).cached {
            KingfisherManager.shared.cache.retrieveImage(forKey: photoURL, options: [.transition(ImageTransition.fade(IMAGE_FADE_SEC)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]) { result in
                switch result {
                case .success(let imageCacheResult):
                    DispatchQueue.main.async {
                        self.underlyingImage = imageCacheResult.image
                    }
                case .failure(let kError):
                    DDLogError("kError:\(kError.localizedDescription)")
                }
            }
        } else {
            guard photoURL != nil, let URL = URL(string: photoURL) else { return }
            downloader.downloadImage(with: URL, options: [.transition(ImageTransition.fade(IMAGE_FADE_SEC)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]) { result in
                switch result {
                case .success(let imageloadingResult):
                    let image = imageloadingResult.image
                    imageCache.store(image, forKey: self.photoURL)
                    DispatchQueue.main.async {
                        self.underlyingImage = image
                    }
                case .failure(let kError):
                    DDLogError("kError:\(kError.localizedDescription)")
                }
            }
        }
    }
    
    open func loadUnderlyingImageAndNotify() {
        guard photoURL != nil, let URL = URL(string: photoURL) else { return }
        
        //修改套件:使用Kingfisher支援Webp格式
        //edit by Eddie 2022/05/06
        let imageCache = KingfisherManager.shared.cache
        let downloader = KingfisherManager.shared.downloader
        
        if imageCache.imageCachedType(forKey: photoURL, processorIdentifier: WebPProcessor.default.identifier).cached {
            KingfisherManager.shared.cache.retrieveImage(forKey: photoURL, options: [.transition(ImageTransition.fade(IMAGE_FADE_SEC)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]) { result in
                switch result {
                case .success(let imageCacheResult):
                    DispatchQueue.main.async {
                        self.underlyingImage = imageCacheResult.image
                        self.loadUnderlyingImageComplete()
                    }
                case .failure(let kError):
                    DDLogError("kError:\(kError.localizedDescription)")
                }
            }
        } else {
            downloader.downloadImage(with: URL, options: [.transition(ImageTransition.fade(IMAGE_FADE_SEC)), .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]) { result in
                switch result {
                case .success(let imageLoadingResult):
                    let image = imageLoadingResult.image
                    imageCache.store(image, forKey: self.photoURL)
                    DispatchQueue.main.async {
                        self.underlyingImage = image
                        self.loadUnderlyingImageComplete()
                    }
                case .failure(let kError):
                    DDLogError("kError:\(kError.localizedDescription)")
                }
            }
        }
    }

    open func loadUnderlyingImageComplete() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION), object: self)
    }
    
}

// MARK: - Static Function

extension SKPhoto {
    public static func photoWithImage(_ image: UIImage) -> SKPhoto {
        return SKPhoto(image: image)
    }
    
    public static func photoWithImageURL(_ url: String) -> SKPhoto {
        return SKPhoto(url: url)
    }
    
    public static func photoWithImageURL(_ url: String, holder: UIImage?) -> SKPhoto {
        return SKPhoto(url: url, holder: holder)
    }
}
