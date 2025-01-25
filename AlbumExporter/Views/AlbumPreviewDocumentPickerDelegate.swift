//AlbumPreviewDocumentPickerDelegate.swift

import UIKit
import Photos

class AlbumPreviewDocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    let album: PHAssetCollection
    // 這裡宣告的 completion 是 (Bool, String?) -> Void
    let completion: (Bool, String?) -> Void

    init(album: PHAssetCollection, completion: @escaping (Bool, String?) -> Void) {
        self.album = album
        self.completion = completion
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let folderURL = urls.first else {
            // 這裡呼叫 completion，給的是 (false, nil)
            completion(false, nil)
            return
        }

        let exporter = FileExporter()
        exporter.exportAlbum(to: folderURL, album: album) { success, errors in
            if success {
                // 這裡呼叫 (true, "路徑...")
                self.completion(true, "Album exported to \(folderURL.path)")
            } else {
                // 這裡呼叫 (false, nil)
                self.completion(false, nil)
            }
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion(false, nil)
    }
}

