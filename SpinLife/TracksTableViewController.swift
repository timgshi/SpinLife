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

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    func loadTracks() {
        guard let playlist = self.playlist else { return }
        self.spotifyManager.request(SpotifyPlaylistRouter.getTracks(playlist: playlist)).responseJSON { response in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
    }

    func makeSpotifyManager() -> SessionManager {
        guard let auth = SPTAuth.defaultInstance() else { return SpotifyWebApiClient.default.sessionManager }
        SpotifyWebApiClient.default.spotifyAuth = auth
        return SpotifyWebApiClient.default.sessionManager
    }

}
