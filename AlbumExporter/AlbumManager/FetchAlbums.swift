// FetchAlbums.swift

import Photos

class FetchAlbums {
    // 獲取相簿清單與其內容
    func fetchAlbums(completion: @escaping ([(name: String, count: Int)]) -> Void) {
        var albumData: [(name: String, count: Int)] = []

        // 明確宣告型別
        let userAlbumFetch: PHFetchResult<PHAssetCollection> =
            PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        let smartAlbumFetch: PHFetchResult<PHAssetCollection> =
            PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)

        // 建立 DispatchGroup 確保完成所有相簿數據的處理
        let dispatchGroup = DispatchGroup()

        // 使用明確的型別陣列
        let albumCollections: [PHFetchResult<PHAssetCollection>] = [userAlbumFetch, smartAlbumFetch]

        albumCollections.forEach { fetchResult in
            fetchResult.enumerateObjects { (album, _, _) in
                dispatchGroup.enter()

                let assets = PHAsset.fetchAssets(in: album, options: nil)
                let albumName = album.localizedTitle ?? "Unnamed Album"
                let assetCount = assets.count

                // 新增相簿數據
                albumData.append((name: albumName, count: assetCount))

                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            // 確保所有數據處理完成後回傳結果
            completion(albumData)
        }
    }
}
