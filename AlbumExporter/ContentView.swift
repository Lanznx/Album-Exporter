// ContentView.swift

import SwiftUI
import Photos

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettingsAlert = false
    @State private var isLoadingAlbums = false // 用於顯示加載進度

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundColor(.primary)

                Text("Welcome to Album Exporter")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 16)

                if appState.isAuthorized {
                    if isLoadingAlbums {
                        ProgressView("Loading Albums...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else {
                        NavigationLink(destination: FolderListView()) {
                            Text("Start Browsing Albums")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    Button(action: openSettings) {
                        Text("Grant Permission")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .navigationTitle("Home")
            .alert(isPresented: $showSettingsAlert) {
                Alert(
                    title: Text("Permission Denied"),
                    message: Text("Please enable photo library access in Settings."),
                    primaryButton: .default(Text("Settings"), action: openSettings),
                    secondaryButton: .cancel()
                )
            }
            .onAppear(perform: handleOnAppear)
        }
    }

    private func handleOnAppear() {
        // 確保首次啟動時檢查權限
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            appState.isAuthorized = true
        case .notDetermined:
            requestPhotoLibraryPermission()
        default:
            appState.isAuthorized = false
            appState.showPermissionAlert = true
        }
    }

    private func requestPhotoLibraryPermission() {
        isLoadingAlbums = true
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
            DispatchQueue.main.async {
                isLoadingAlbums = false
                if newStatus == .authorized || newStatus == .limited {
                    appState.isAuthorized = true
                } else {
                    appState.isAuthorized = false
                    appState.showPermissionAlert = true
                }
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
