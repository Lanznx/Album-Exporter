// AlbumPreviewViewController.swift

import UIKit
import Photos

class AlbumPreviewViewController: UIViewController, UICollectionViewDataSource {
    private let album: PHAssetCollection
    private var images: [UIImage] = []
    private let collectionView: UICollectionView
    private let activityIndicator = UIActivityIndicatorView(style: .large)

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
        setupActivityIndicator()
        loadAlbumContent()
    }

    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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

    private func loadAlbumContent() {
        activityIndicator.startAnimating()

        let fetcher = AlbumContentFetcher()
        fetcher.fetchAssets(from: album, targetSize: CGSize(width: 300, height: 300)) { [weak self] fetchedImages in
            DispatchQueue.main.async {
                self?.images = fetchedImages
                self?.collectionView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let imageView = UIImageView(image: images[indexPath.row])
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = cell.contentView.bounds
        cell.contentView.addSubview(imageView)
        return cell
    }
}
