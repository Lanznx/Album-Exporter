import SwiftUI
import Photos

struct FolderListView: View {
    @State private var smartAlbums: [PHAssetCollection] = [] // 智能相簿列表
    @State private var userAlbums: [PHAssetCollection] = []  // 用戶相簿列表

    var body: some View {
        List {
            // 智能相簿
            if !smartAlbums.isEmpty {
                Section(header: Text("Smart Albums")) {
                    ForEach(smartAlbums, id: \.localIdentifier) { album in
                        NavigationLink(destination: AlbumPreviewView(album: album)) {
                            Text("\(album.localizedTitle ?? "Unnamed Album")")
                        }
                    }
                }
            }

            // 用戶相簿
            if !userAlbums.isEmpty {
                Section(header: Text("My Albums")) {
                    ForEach(userAlbums, id: \.localIdentifier) { album in
                        NavigationLink(destination: AlbumPreviewView(album: album)) {
                            Text("\(album.localizedTitle ?? "Unnamed Album")")
                        }
                    }
                }
            }
        }
        .navigationTitle("相簿列表") // 設置導航欄標題
        .onAppear(perform: loadAlbums) // 加載相簿數據
    }

    private func loadAlbums() {
        // 確保已獲取相簿權限
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            guard status == .authorized || status == .limited else { return }

            // 加載智能相簿
            let smartAlbumsFetch = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum, subtype: .any, options: nil
            )
            var fetchedSmartAlbums: [PHAssetCollection] = []
            smartAlbumsFetch.enumerateObjects { collection, _, _ in
                fetchedSmartAlbums.append(collection)
            }

            // 加載用戶相簿
            let userAlbumsFetch = PHAssetCollection.fetchAssetCollections(
                with: .album, subtype: .any, options: nil
            )
            var fetchedUserAlbums: [PHAssetCollection] = []
            userAlbumsFetch.enumerateObjects { collection, _, _ in
                fetchedUserAlbums.append(collection)
            }

            // 更新狀態
            DispatchQueue.main.async {
                smartAlbums = fetchedSmartAlbums
                userAlbums = fetchedUserAlbums
            }
        }
    }
}
