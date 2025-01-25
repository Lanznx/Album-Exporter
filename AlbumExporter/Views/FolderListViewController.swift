// FolderListViewController.swift

import UIKit
import Photos

class FolderListViewController: UIViewController {
    private let tableView = UITableView()
    private let greetingButton = UIButton(type: .system) // 按鈕
    private var folders: [(name: String, collections: [PHAssetCollection])] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Folders"
        view.backgroundColor = .white

        setupGreetingButton()   // 設定按鈕
        setupTableView()        // 設定表格
        setupActivityIndicator() // 設定載入指示器
        loadFolders()           // 加載相簿資料
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        debugViewHierarchy() // 打印視圖層級
    }

    private func setupGreetingButton() {
        greetingButton.setTitle("Say Hi", for: .normal)
        greetingButton.backgroundColor = .systemBlue
        greetingButton.setTitleColor(.white, for: .normal)
        greetingButton.layer.cornerRadius = 10
        greetingButton.translatesAutoresizingMaskIntoConstraints = false
        greetingButton.addTarget(self, action: #selector(greetingButtonTapped), for: .touchUpInside)

        view.addSubview(greetingButton)
        view.bringSubviewToFront(greetingButton)

        NSLayoutConstraint.activate([
            greetingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            greetingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            greetingButton.widthAnchor.constraint(equalToConstant: 150),
            greetingButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func greetingButtonTapped() {
        let alert = UIAlertController(title: "你好", message: "歡迎使用這個應用程式！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FolderCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: greetingButton.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func debugViewHierarchy() {
        print("View Hierarchy: \(view.subviews)") // 打印視圖層級
        print("Greeting Button Frame: \(greetingButton.frame)") // 打印按鈕位置
    }

    private func loadFolders() {
        activityIndicator.startAnimating()

        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    self.fetchFolders()
                } else {
                    self.activityIndicator.stopAnimating()
                    self.showPermissionAlert()
                }
            }
        }
    }

    private func fetchFolders() {
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        var smartAlbumCollections: [PHAssetCollection] = []
        smartAlbums.enumerateObjects { (collection, _, _) in
            smartAlbumCollections.append(collection)
        }

        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        var userAlbumCollections: [PHAssetCollection] = []
        userAlbums.enumerateObjects { (collection, _, _) in
            userAlbumCollections.append(collection)
        }

        DispatchQueue.main.async {
            self.folders = [
                (name: "Smart Albums", collections: smartAlbumCollections),
                (name: "My Albums", collections: userAlbumCollections)
            ]
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }

    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Permission Denied",
            message: "Please enable photo library access in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension FolderListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return folders.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return folders[section].name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders[section].collections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        let collection = folders[indexPath.section].collections[indexPath.row]
        let assetCount = PHAsset.fetchAssets(in: collection, options: nil).count
        cell.textLabel?.text = "\(collection.localizedTitle ?? "Unnamed Folder") (\(assetCount))"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFolder = folders[indexPath.section].collections[indexPath.row]
        let albumListVC = AlbumListViewController(albums: [selectedFolder])
        navigationController?.pushViewController(albumListVC, animated: true)
    }
}
