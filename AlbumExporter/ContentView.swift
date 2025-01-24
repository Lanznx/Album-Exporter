// ContentView.swift
import SwiftUI
import Photos
import UIKit

struct ContentView: View {
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundColor(.primary)

                Text("歡迎使用相簿匯出工具")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 16)

                Button(action: checkPermission) {
                    Text("檢查相簿權限")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.bottom, 20)

                // 新增 NavigationLink 跳轉到相簿列表頁面
                NavigationLink(destination: FolderListView()) {
                    Text("開始查看相簿")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            .padding()
            .alert(isPresented: $showPermissionAlert) {
                Alert(
                    title: Text("相簿權限被拒絕"),
                    message: Text("請前往系統設定開啟相簿權限"),
                    primaryButton: .default(Text("設定"), action: openSettings),
                    secondaryButton: .cancel()
                )
            }
            .navigationTitle("主頁面")
        }
    }

    private func checkPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .restricted || status == .denied {
            showPermissionAlert = true
        } else {
            print("相簿權限正常")
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
