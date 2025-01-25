// AlbumPreviewView.swift

import SwiftUI
import Photos
import UIKit

struct AlbumPreviewView: View {
    let album: PHAssetCollection
    @State private var photos: [UIImage] = []
    @State private var isLoading = true
    @State private var showExportError = false
    @State private var exportSuccessMessage: ExportMessage? = nil
    @State private var docPickerDelegate: AlbumPreviewDocumentPickerDelegate?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Button(action: openDocumentPicker) {
                Text("Export Album")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
            .alert(isPresented: $showExportError) {
                Alert(title: Text("Error"), message: Text("Failed to export album."), dismissButton: .default(Text("OK")))
            }
            .alert(item: $exportSuccessMessage) { message in
                Alert(title: Text("Success"), message: Text(message.message), dismissButton: .default(Text("OK")))
            }


            if isLoading {
                ProgressView("Loading Photos...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if photos.isEmpty {
                Text("No photos available")
                    .foregroundColor(.secondary)
                    .font(.headline)
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                        spacing: 10
                    ) {
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
            }
        }
        .navigationTitle(album.localizedTitle ?? "Unnamed Album")
        .onAppear(perform: loadPhotos)
    }

    private func loadPhotos() {
        isLoading = true
        let fetcher = AlbumContentFetcher()
        fetcher.fetchAssets(from: album, targetSize: CGSize(width: 300, height: 300)) { images in
            DispatchQueue.main.async {
                self.photos = images
                self.isLoading = false
            }
        }
    }

    private func openDocumentPicker() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
        picker.allowsMultipleSelection = false
        picker.delegate = docPickerDelegate

        // 獲取當前的活躍 UIWindowScene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            keyWindow.rootViewController?.present(picker, animated: true)
        } else {
            print("Error: Unable to find key window to present document picker.")
        }
    }

}

struct ExportMessage: Identifiable {
    let id = UUID() // 自動生成唯一標識符
    let message: String
}
