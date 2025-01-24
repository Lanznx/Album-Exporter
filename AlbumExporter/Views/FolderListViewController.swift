
// FolderListViewController.swift
import UIKit
import Photos

class FolderListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var folders: [(name: String, collections: [PHAssetCollection])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Folders"
        view.backgroundColor = .white

        setupTableView()
        loadFolders()
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FolderCell")
        view.addSubview(tableView)
    }

    private func loadFolders() {
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        var smartAlbumCollections: [PHAssetCollection] = []
        smartAlbums.enumerateObjects { (collection, _, _) in
            smartAlbumCollections.append(collection)
        }
        folders.append((name: "Smart Albums", collections: smartAlbumCollections))

        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        var userAlbumCollections: [PHAssetCollection] = []
        userAlbums.enumerateObjects { (collection, _, _) in
            userAlbumCollections.append(collection)
        }
        folders.append((name: "My Albums", collections: userAlbumCollections))

        tableView.reloadData()
    }

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
