import SwiftUI
import Photos

class AppState: ObservableObject {
    @Published var isAuthorized: Bool = false
}

@main
struct AlbumExporterApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    requestPhotoLibraryAuthorization()
                }
        }
    }
    
    private func requestPhotoLibraryAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        appState.isAuthorized = true
                        print("已授權訪問相簿")
                    } else {
                        appState.isAuthorized = false
                        print("訪問相簿權限被拒絕")
                    }
                }
            }
        case .restricted, .denied:
            appState.isAuthorized = false
            print("訪問相簿權限受限或被拒絕")
        case .authorized, .limited:
            appState.isAuthorized = true
            print("相簿權限已授權")
        @unknown default:
            print("未知的相簿權限狀態")
        }
    }
}
