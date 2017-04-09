//
//  AppDelegate.swift
//  SpinLife
//
//  Created by Tim Shi on 2017/04/09.
//  Copyright © 2017 Tim Shi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var spotifyAuth: SPTAuth?
    var spotifyPlayer: SPTAudioStreamingController?
    var spotifyAuthViewController: UIViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        self.spotifyAuth = SPTAuth.defaultInstance()
        self.spotifyPlayer = SPTAudioStreamingController.sharedInstance()
        self.spotifyAuth?.clientID = Constants.spotifyClientId
        self.spotifyAuth?.redirectURL = URL(string: Constants.spotifyRedirectUrl)
        self.spotifyAuth?.sessionUserDefaultsKey = Constants.spotifySessionUserDefaultsKey
        self.spotifyAuth?.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistReadCollaborativeScope, SPTAuthUserLibraryModifyScope, SPTAuthPlaylistModifyPrivateScope]

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if (self.spotifyAuth?.canHandle(url))! {
            self.spotifyAuth?.handleAuthCallback(withTriggeredAuthURL: url, callback: { (err, session) in
                if (err != nil) {
                    print("Spotify auth error: \(err.debugDescription)")
                } else {
                    self.spotifyAuth?.session = session
                }
                NotificationCenter.default.post(name: .spotifySessionUpdated, object: nil)
            })
            return true
        }
        return false
    }


}

