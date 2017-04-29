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
    case getTracks(playlist: SpotifyPlaylist)

    static let baseURLString = SpotifyWebApiClient.spotifyApiBase

    var method: HTTPMethod {
        switch self {
            case .getMyPlaylists:
                return .get
            case .getPlaylistTracks:
                return .get
            case .getTracks:
                return .get
        }
    }

    var path: String {
        switch self {
            case .getMyPlaylists:
                return "/me/playlists"
            case .getPlaylistTracks(let userId, let playlistId):
                return "/users/\(userId)/playlists/\(playlistId)/tracks"
            case .getTracks(let playlist):
                return "/users/\(playlist.ownerId)/playlists/\(playlist.id)/tracks"
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

enum SpotifyTrackRouter: URLRequestConvertible {

    case getAudioFeaturesBulk(tracks: [SpotifyTrack])

    static let baseURLString = SpotifyWebApiClient.spotifyApiBase

    var method: HTTPMethod {
        switch self {
        case .getAudioFeaturesBulk:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getAudioFeaturesBulk:
            return "/audio-features"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try SpotifyPlaylistRouter.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue


        switch self {
        case .getAudioFeaturesBulk(let tracks):
            let ids = tracks.map { track in track.id }
            let idString = ids.reduce("") { text, id in "\(text),\(id)" }
            let parameters = ["ids": idString]
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }

        return urlRequest
    }

}

struct SpotifyPlaylist: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
    let id: String
    let name: String
    let href: String
    let uri: String
    let ownerId: String

    var description: String {
        return "Playlist: { id: \(id), name: \(name), href: \(href) }"
    }

    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let id = representation["id"] as? String,
            let name = representation["name"] as? String,
            let href = representation["href"] as? String,
            let uri = representation["uri"] as? String,
            let owner = representation["owner"] as? [String: Any],
            let ownerId = owner["id"] as? String
        else { return nil }

        self.id = id
        self.name = name
        self.href = href
        self.uri = uri
        self.ownerId = ownerId
    }

    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [SpotifyPlaylist] {
        var collection: [SpotifyPlaylist] = []

        if let playlistResult = representation as? [String: Any] {
            if let playlistItems = playlistResult["items"] as? [[String: Any]] {
                for itemRepresentation in playlistItems {
                    if let item = self.init(response: response, representation: itemRepresentation) {
                        collection.append(item)
                    }
                }
            }
        }

        return collection
    }

}

struct SpotifyTrack: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
    let id: String
    let name: String
    let href: String
    let uri: String

    var description: String {
        return "Playlist: { id: \(id), name: \(name), href: \(href) }"
    }

    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let id = representation["id"] as? String,
            let name = representation["name"] as? String,
            let href = representation["href"] as? String,
            let uri = representation["uri"] as? String
            else { return nil }

        self.id = id
        self.name = name
        self.href = href
        self.uri = uri
    }

    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [SpotifyTrack] {
        var collection: [SpotifyTrack] = []

        if let tracksResult = representation as? [String: Any] {
            if let tracksResultItems = tracksResult["items"] as? [[String: Any]] {
                for itemRepresentation in tracksResultItems {
                    if let trackRepresentation = itemRepresentation["track"] as? [String: Any] {
                        if let item = self.init(response: response, representation: trackRepresentation) {
                            collection.append(item)
                        }
                    }
                }
            }
        }

        return collection
    }
    
}

enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case xmlSerialization(error: Error)
    case objectSerialization(reason: String)
}

protocol ResponseObjectSerializable {
    init?(response: HTTPURLResponse, representation: Any)
}

extension DataRequest {
    func responseObject<T: ResponseObjectSerializable>(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<T>) -> Void)
        -> Self
    {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil else { return .failure(BackendError.network(error: error!)) }

            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, nil)

            guard case let .success(jsonObject) = result else {
                return .failure(BackendError.jsonSerialization(error: result.error!))
            }

            guard let response = response, let responseObject = T(response: response, representation: jsonObject) else {
                return .failure(BackendError.objectSerialization(reason: "JSON could not be serialized: \(jsonObject)"))
            }

            return .success(responseObject)
        }

        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

extension DataRequest {
    @discardableResult
    func responseCollection<T: ResponseCollectionSerializable>(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self
    {
        let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
            guard error == nil else { return .failure(BackendError.network(error: error!)) }

            let jsonSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonSerializer.serializeResponse(request, response, data, nil)

            guard case let .success(jsonObject) = result else {
                return .failure(BackendError.jsonSerialization(error: result.error!))
            }

            guard let response = response else {
                let reason = "Response collection could not be serialized due to nil response."
                return .failure(BackendError.objectSerialization(reason: reason))
            }

            return .success(T.collection(from: response, withRepresentation: jsonObject))
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

protocol ResponseCollectionSerializable {
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self]
}

extension ResponseCollectionSerializable where Self: ResponseObjectSerializable {
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self] {
        var collection: [Self] = []

        if let representation = representation as? [String: Any] {
            for itemRepresentation in representation {
                if let item = Self(response: response, representation: itemRepresentation) {
                    collection.append(item)
                }
            }
        }

        return collection
    }
}
