import Photos

class FetchAlbums {
    // 獲取相簿清單與其內容
    func fetchAlbums() -> [(name: String, count: Int)] {
        var albumData: [(name: String, count: Int)] = []

        // 設置相簿獲取選項
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
        
        // 獲取使用者的相簿清單
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
        userAlbums.enumerateObjects { (collection, _, _) in
            // 計算相簿內的資產數量
            let assets = PHAsset.fetchAssets(in: collection, options: nil)
            let albumName = collection.localizedTitle ?? "Unnamed Album"
            let assetCount = assets.count
            
            // 新增相簿資訊到清單
            albumData.append((name: albumName, count: assetCount))
        }
        
        return albumData
    }
}
