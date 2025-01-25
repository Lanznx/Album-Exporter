// AlbumExporterApp.swift

import SwiftUI
import Photos

class AppState: ObservableObject {
    @Published var isAuthorized: Bool = false
    @Published var showPermissionAlert: Bool = false
}

@main
struct AlbumExporterApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear(perform: checkPhotoLibraryAuthorization)
        }
    }
    
    private func checkPhotoLibraryAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    self.handleAuthorizationStatus(newStatus)
                }
            }
        case .restricted, .denied:
            DispatchQueue.main.async {
                self.appState.isAuthorized = false
                self.appState.showPermissionAlert = true
            }
        case .authorized, .limited:
            DispatchQueue.main.async {
                self.appState.isAuthorized = true
            }
        @unknown default:
            print("Unknown authorization status")
        }
    }

    private func handleAuthorizationStatus(_ status: PHAuthorizationStatus) {
        if status == .authorized || status == .limited {
            appState.isAuthorized = true
        } else {
            appState.isAuthorized = false
            appState.showPermissionAlert = true
        }
    }
}
