import Foundation
import Photos

class FileExporter {
    // 檢測外接硬碟
    func detectExternalDrives() -> [URL] {
        let fileManager = FileManager.default
        let paths = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: [])

        guard let drives = paths else { return [] }
        return drives.filter { $0.path.contains("/Volumes/") } // 外接硬碟一般掛載於 /Volumes
    }

    // 匯出指定相簿到目標路徑
    func exportAlbum(to destinationURL: URL, album: PHAssetCollection, completion: @escaping (Bool, Error?) -> Void) {
        let assets = PHAsset.fetchAssets(in: album, options: nil)
        let imageManager = PHImageManager.default()

        var exportSuccess = true
        let exportGroup = DispatchGroup()

        assets.enumerateObjects { (asset, _, _) in
            exportGroup.enter()
            let options = PHImageRequestOptions()
            options.isSynchronous = false

            let resource = PHAssetResource.assetResources(for: asset).first
            let originalFilename = resource?.originalFilename ?? "\(UUID().uuidString).jpg"

            imageManager.requestImageDataAndOrientation(for: asset, options: options) { (data, _, _, _) in
                defer { exportGroup.leave() }
                guard let data = data else {
                    print("無法獲取圖像數據：\(asset)")
                    exportSuccess = false
                    return
                }

                let fileURL = destinationURL.appendingPathComponent(originalFilename)
                do {
                    try data.write(to: fileURL)
                } catch {
                    print("寫入文件失敗：\(error.localizedDescription)")
                    exportSuccess = false
                }
            }
        }

        exportGroup.notify(queue: .main) {
            completion(exportSuccess, nil)
        }
    }

}
