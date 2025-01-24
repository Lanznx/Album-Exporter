
// AlbumPreviewViewController.swift
import UIKit
import Photos

class AlbumPreviewViewController: UIViewController {
    private let album: PHAssetCollection
    private var images: [UIImage] = []
    private let collectionView: UICollectionView

    init(album: PHAssetCollection) {
        self.album = album
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.localizedTitle
        view.backgroundColor = .white
        setupCollectionView()
        setupExportButton()
        loadAlbumContent()
    }

    private func setupCollectionView() {
        collectionView.frame = view.bounds
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        view.addSubview(collectionView)
    }

    private func setupExportButton() {
        let exportButton = UIButton(type: .system)
        exportButton.setTitle("Export Album", for: .normal)
        exportButton.frame = CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50)
        exportButton.addTarget(self, action: #selector(exportAlbum), for: .touchUpInside)
        view.addSubview(exportButton)
    }

    @objc private func exportAlbum() {
        let exporter = FileExporter()
        let externalDrives = exporter.detectExternalDrives()

        if externalDrives.isEmpty {
            let alert = UIAlertController(title: "No External Drives", message: "Please connect an external drive to export the album.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            let destinationURL = externalDrives.first! // 假設用戶只連接了一個硬碟
            exporter.exportAlbum(to: destinationURL, album: album) { success, error in
                if success {
                    let alert = UIAlertController(title: "Export Successful", message: "Album has been exported to \(destinationURL.path)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Export Failed", message: error?.localizedDescription ?? "Unknown error occurred", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func loadAlbumContent() {
        let fetcher = AlbumContentFetcher()
        images = fetcher.fetchAssets(from: album)
        collectionView.reloadData()
    }
}

extension AlbumPreviewViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        let imageView = UIImageView(image: images[indexPath.row])
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)
        imageView.frame = cell.contentView.bounds
        return cell
    }
}
