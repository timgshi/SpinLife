//
//  PlaylistsTableViewController.swift
//  SpinLife
//
//  Created by Tim Shi on 2017/04/09.
//  Copyright © 2017 Tim Shi. All rights reserved.
//

import UIKit
import Alamofire
import Alexandria

class PlaylistsTableViewController: UITableViewController {

    lazy var spotifyManager: SessionManager = self.makeSpotifyManager()
    var playlists = [SpotifyPlaylist]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Playlists"
        let estimatedRowHeight = CGFloat(100.0)
        self.tableView.registerCell(PlaylistsTableViewCell.self)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = estimatedRowHeight
        self.loadPlaylists()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueCell(for: indexPath) as PlaylistsTableViewCell
        let playlist = self.playlist(atIndexPath: indexPath)
        cell.nameLabel.text = playlist.name
        return cell
    }

    func loadPlaylists() {
        self.spotifyManager.request(SpotifyPlaylistRouter.getMyPlaylists()).responseCollection { (response: DataResponse<[SpotifyPlaylist]>) in
            debugPrint(response)

            if let playlists = response.result.value {
                self.playlists = playlists
                self.tableView.reloadData()
            }
        }

    }

    func playlist(atIndexPath indexPath: IndexPath) -> SpotifyPlaylist {
        return self.playlists[indexPath.row]
    }

    func makeSpotifyManager() -> SessionManager {
        guard let auth = SPTAuth.defaultInstance() else { return SpotifyWebApiClient.default.sessionManager }
        SpotifyWebApiClient.default.spotifyAuth = auth
        return SpotifyWebApiClient.default.sessionManager
    }

}
