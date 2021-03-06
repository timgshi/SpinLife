//
//  TracksTableViewController.swift
//  SpinLife
//
//  Created by Tim Shi on 2017/04/29.
//  Copyright © 2017 Tim Shi. All rights reserved.
//

import UIKit
import Alamofire
import Alexandria

class TracksTableViewController: UITableViewController {

    lazy var spotifyManager: SessionManager = self.makeSpotifyManager()
    var playlist: SpotifyPlaylist? {
        didSet {
            self.loadTracks()
        }
    }
    var tracks = [SpotifyTrack]()
    var audioFeatures = [SpotifyTrackAudioFeatures]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let estimatedRowHeight = CGFloat(100.0)
        self.tableView.registerCell(TracksTableViewCell.self)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = estimatedRowHeight
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueCell(for: indexPath) as TracksTableViewCell
        let track = self.track(atIndexPath: indexPath)
        cell.nameLabel.text = track.name
        if track.audioFeatures != nil {
            cell.tempo = Int(track.audioFeatures?.tempo ?? 0)
        }
        return cell
    }

    func loadTracks() {
        guard let playlist = self.playlist else { return }
        self.title = playlist.name
        self.spotifyManager.request(SpotifyPlaylistRouter.getTracks(playlist: playlist)).responseCollection { (response: DataResponse<[SpotifyTrack]>) in

            if let tracks = response.result.value {
                self.tracks = tracks
                self.tableView.reloadData()
                self.spotifyManager.request(SpotifyTrackRouter.getAudioFeaturesBulk(tracks: tracks)).responseCollection { (audioFeaturesResponse: DataResponse<[SpotifyTrackAudioFeatures]>) in

                    if let audioFeatures = audioFeaturesResponse.result.value {
                        self.audioFeatures = audioFeatures
                        for (index, audioFeature) in self.audioFeatures.enumerated() {
                            self.tracks[index].audioFeatures = audioFeature
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    func track(atIndexPath indexPath: IndexPath) -> SpotifyTrack {
        return self.tracks[indexPath.row]
    }

    func index(forTrack track: SpotifyTrack) -> Int {
        guard let index = self.tracks.index(of: track) else { return -1 }
        return index
    }

    func makeSpotifyManager() -> SessionManager {
        guard let auth = SPTAuth.defaultInstance() else { return SpotifyWebApiClient.default.sessionManager }
        SpotifyWebApiClient.default.spotifyAuth = auth
        return SpotifyWebApiClient.default.sessionManager
    }

}
