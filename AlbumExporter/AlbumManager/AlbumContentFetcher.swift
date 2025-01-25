// AlbumContentFetcher.swift

import Photos
import UIKit

class AlbumContentFetcher {
    // MARK: - Fetch assets from a specific album
    /// 獲取指定相簿內的照片與影片
    ///
    /// - Parameters:
    ///   - album: 指定的 PHAssetCollection 相簿
    ///   - targetSize: 縮圖的目標大小，預設為 150x150
    ///   - completion: 完成回呼，回傳照片列表
    func fetchAssets(
        from album: PHAssetCollection,
        targetSize: CGSize = CGSize(width: 150, height: 150),
        completion: @escaping ([UIImage]) -> Void
    ) {
        // 照片結果列表
        var images: [UIImage] = []
        // 從相簿中獲取資產
        let assets = PHAsset.fetchAssets(in: album, options: nil)
        // 高效圖片管理器
        let imageManager = PHCachingImageManager()

        // 設定圖片請求選項
        let options = PHImageRequestOptions()
        options.isSynchronous = false // 非同步請求
        options.deliveryMode = .highQualityFormat // 確保高品質圖片
        options.resizeMode = .exact // 僅拉伸到指定大小

        // 使用 DispatchGroup 確保所有圖片處理完成
        let dispatchGroup = DispatchGroup()

        // 遍歷相簿中的所有資產
        assets.enumerateObjects { (asset, _, _) in
            dispatchGroup.enter() // 標記進入處理
            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit, // 適合框架顯示
                options: options
            ) { (image, _) in
                if let image = image {
                    images.append(image) // 保存圖片到列表
                }
                dispatchGroup.leave() // 標記處理結束
            }
        }

        // 等待所有圖片處理完成後，回傳結果
        dispatchGroup.notify(queue: .main) {
            completion(images)
        }
    }
}
