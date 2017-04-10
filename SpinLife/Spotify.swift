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

    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
    var spotifyAuth: SPTAuth? {
        didSet {
            self.configureForAuth()
        }
    }

    static let `default`: SpotifyWebApiClient = {
        SpotifyWebApiClient()
    }()

    func configureForAuth() {
        guard let accessToken = self.spotifyAuth?.session.accessToken else { return }
        self.sessionManager.adapter = SpotifyAccessTokenAdapter(accessToken: accessToken)
        
    }

}

class SpotifyAccessTokenAdapter: RequestAdapter {

    static let spotifyApiBase = "https://api.spotify.com/v1"

    private let accessToken: String

    public init(accessToken: String) {
        self.accessToken = accessToken
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(SpotifyAccessTokenAdapter.spotifyApiBase) {
            urlRequest.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}
