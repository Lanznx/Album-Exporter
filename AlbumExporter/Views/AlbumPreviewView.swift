import SwiftUI
import Photos

struct AlbumPreviewView: View {
    let album: PHAssetCollection // 接收選中的相簿
    @State private var photos: [UIImage] = [] // 保存相簿內的照片

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(photos, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                }
            }
            .padding()
        }
        .navigationTitle(album.localizedTitle ?? "Unnamed Album")
        .onAppear(perform: loadPhotos) // 加載照片數據
    }

    private func loadPhotos() {
        let assets = PHAsset.fetchAssets(in: album, options: nil) // 獲取相簿中的照片
        let imageManager = PHCachingImageManager()
        var fetchedPhotos: [UIImage] = []

        assets.enumerateObjects { asset, _, _ in
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 300, height: 300),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                if let image = image {
                    fetchedPhotos.append(image)
                }
            }
        }

        DispatchQueue.main.async {
            photos = fetchedPhotos
        }
    }
}
