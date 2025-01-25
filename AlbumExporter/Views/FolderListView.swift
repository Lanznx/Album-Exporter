// FolderListView.swift

import SwiftUI
import Photos

struct FolderListView: View {
    @State private var smartAlbums: [PHAssetCollection] = [] // 智能相簿列表
    @State private var userAlbums: [PHAssetCollection] = []  // 用戶相簿列表
    @State private var isLoading = true // 加載狀態
    @State private var showPermissionAlert = false // 權限警告

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Albums...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
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
            }
        }
        .navigationTitle("Albums")
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Permission Denied"),
                message: Text("Please enable photo library access in Settings."),
                primaryButton: .default(Text("Settings"), action: openSettings),
                secondaryButton: .cancel()
            )
        }
        .onAppear(perform: loadAlbums)
    }

    private func loadAlbums() {
        isLoading = true // 開始加載
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    fetchAlbums()
                } else {
                    isLoading = false
                    showPermissionAlert = true
                }
            }
        }
    }

    private func fetchAlbums() {
        // 加載智能相簿
        let smartAlbumsFetch = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        var fetchedSmartAlbums: [PHAssetCollection] = []
        smartAlbumsFetch.enumerateObjects { collection, _, _ in
            fetchedSmartAlbums.append(collection)
        }

        // 加載用戶相簿
        let userAlbumsFetch = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        var fetchedUserAlbums: [PHAssetCollection] = []
        userAlbumsFetch.enumerateObjects { collection, _, _ in
            fetchedUserAlbums.append(collection)
        }

        // 更新狀態
        DispatchQueue.main.async {
            self.smartAlbums = fetchedSmartAlbums
            self.userAlbums = fetchedUserAlbums
            self.isLoading = false
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
