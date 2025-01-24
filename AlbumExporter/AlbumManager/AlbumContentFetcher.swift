
import Photos
import UIKit

class AlbumContentFetcher {
    // 獲取指定相簿內的照片與影片
    func fetchAssets(from album: PHAssetCollection) -> [UIImage] {
        var images: [UIImage] = []
        
        let assets = PHAsset.fetchAssets(in: album, options: nil)
        let imageManager = PHImageManager.default()
        
        // 載入每個資產的縮圖
        assets.enumerateObjects { (asset, _, _) in
            let options = PHImageRequestOptions()
            options.isSynchronous = true // 同步獲取，方便測試
            
            imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 150, height: 150),
                contentMode: .aspectFit,
                options: options
            ) { (image, _) in
                if let image = image {
                    images.append(image)
                }
            }
        }
        
        return images
    }
}
