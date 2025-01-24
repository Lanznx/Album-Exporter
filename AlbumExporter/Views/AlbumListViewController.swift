import UIKit
import Photos

class AlbumListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let albums: [PHAssetCollection]
    private let tableView = UITableView()

    init(albums: [PHAssetCollection]) {
        self.albums = albums
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Albums"
        view.backgroundColor = .white

        setupTableView()
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AlbumCell")
        view.addSubview(tableView)
    }

    // MARK: - TableView 資料源方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath)
        let album = albums[indexPath.row]
        let assetCount = PHAsset.fetchAssets(in: album, options: nil).count
        cell.textLabel?.text = "\(album.localizedTitle ?? "Unnamed Album") (\(assetCount))"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - TableView 點擊事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAlbum = albums[indexPath.row]
        let previewVC = AlbumPreviewViewController(album: selectedAlbum)
        navigationController?.pushViewController(previewVC, animated: true)
    }
}
