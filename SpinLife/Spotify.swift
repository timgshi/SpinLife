//
//  Spotify.swift
//  SpinLife
//
//  Created by Tim Shi on 2017/04/10.
//  Copyright © 2017 Tim Shi. All rights reserved.
//

import Foundation
import Alamofire

class SpotifyWebApiClient {

    let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
    var spotifyAuth: SPTAuth? {
        didSet {
            self.configureForAuth()
        }
    }
    static let spotifyApiBase = "https://api.spotify.com/v1"

    static let `default`: SpotifyWebApiClient = {
        SpotifyWebApiClient()
    }()

    func configureForAuth() {
        guard let accessToken = self.spotifyAuth?.session.accessToken else { return }
        self.sessionManager.adapter = SpotifyAccessTokenAdapter(accessToken: accessToken)
    }

}

class SpotifyAccessTokenAdapter: RequestAdapter {

    private let accessToken: String

    public init(accessToken: String) {
        self.accessToken = accessToken
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(SpotifyWebApiClient.spotifyApiBase) {
            urlRequest.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}

enum SpotifyPlaylistRouter: URLRequestConvertible {

    case getMyPlaylists()
    case getPlaylistTracks(userId: String, playlistId: String)

    static let baseURLString = SpotifyWebApiClient.spotifyApiBase

    var method: HTTPMethod {
        switch self {
        case .getMyPlaylists:
            return .get
        case .getPlaylistTracks:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getMyPlaylists:
            return "/me/playlists"
        case .getPlaylistTracks(let userId, let playlistId):
            return "/\(userId)/playlists/\(playlistId)/tracks"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try SpotifyPlaylistRouter.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }

}
