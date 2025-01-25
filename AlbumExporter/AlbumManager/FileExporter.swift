// FileExporter.swift
import Foundation
import Photos

class FileExporter {
    // 檢測外接硬碟
    func detectExternalDrives() -> [URL] {
        let fileManager = FileManager.default
        let paths = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: [])
        return paths?.filter { $0.path.hasPrefix("/Volumes/") } ?? []
    }

    // 匯出指定相簿到目標路徑
    func exportAlbum(to destinationURL: URL, album: PHAssetCollection, completion: @escaping (Bool, [Error]) -> Void) {
        let assets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: album, options: nil)
        let imageManager = PHImageManager.default()

        let dispatchGroup = DispatchGroup()
        var exportErrors: [Error] = []

        assets.enumerateObjects { (asset: PHAsset, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            dispatchGroup.enter()

            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat

            imageManager.requestImageDataAndOrientation(for: asset, options: options) {
                (data, dataUTI, orientation, info) in
                
                defer { dispatchGroup.leave() }

                // 從 info 字典中取出錯誤
                let error = info?[PHImageErrorKey] as? Error
                guard error == nil, let data = data else {
                    exportErrors.append(error ?? NSError(domain: "ExportError", code: -1, userInfo: nil))
                    return
                }

                let fileName = self.generateUniqueFileName(for: asset, in: destinationURL)
                let fileURL = destinationURL.appendingPathComponent(fileName)

                do {
                    try data.write(to: fileURL)
                } catch {
                    exportErrors.append(error)
                }
            }

        }

        dispatchGroup.notify(queue: .main) {
            completion(exportErrors.isEmpty, exportErrors)
        }
    }

    // 為檔案生成唯一名稱
    private func generateUniqueFileName(for asset: PHAsset, in directory: URL) -> String {
        let originalName = PHAssetResource.assetResources(for: asset).first?.originalFilename ?? "Unnamed.jpg"
        let fileManager = FileManager.default
        var uniqueName = originalName
        var counter = 1

        while fileManager.fileExists(atPath: directory.appendingPathComponent(uniqueName).path) {
            let fileExtension = (originalName as NSString).pathExtension
            let baseName = (originalName as NSString).deletingPathExtension
            uniqueName = "\(baseName)_\(counter).\(fileExtension)"
            counter += 1
        }

        return uniqueName
    }
}
