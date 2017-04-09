//
//  LoginViewController.swift
//  SpinLife
//
//  Created by Tim Shi on 2017/04/09.
//  Copyright © 2017 Tim Shi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, SFSafariViewControllerDelegate {

    var authViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: .spotifySessionUpdated,
                                               object: nil,
                                               queue: OperationQueue.main) { (notification) in
            self.handleSessionUpdated()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let auth = SPTAuth.defaultInstance() else { return }
        guard let session = auth.session else { return }
        if (session.isValid()) {
            print("\(session.accessToken)")
            self.loginSuccessful()
        }
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.openLoginPage()
    }
    
    func openLoginPage() {
        let auth = SPTAuth.defaultInstance()
        if (SPTAuth.supportsApplicationAuthentication()) {
            guard let url = auth?.spotifyAppAuthenticationURL() else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            guard let url = auth?.spotifyWebAuthenticationURL() else { return }
            self.authViewController = self.authViewControllerWithUrl(url: url)
            self.definesPresentationContext = true
            guard let authVC = self.authViewController else { return }
            self.present(authVC, animated: true, completion: nil)
        }
    }

    func loginSuccessful() {
        let playlistsVC = PlaylistsTableViewController()
        self.navigationController?.pushViewController(playlistsVC, animated: true)
    }

    func authViewControllerWithUrl(url: URL) -> UIViewController {
        let safari = SFSafariViewController(url: url)
        safari.delegate = self
        return safari
    }

    func handleSessionUpdated() {
        self.dismiss(animated: true, completion: nil)
        let auth = SPTAuth.defaultInstance()
        if (auth?.session != nil && (auth?.session.isValid())!) {
//            self.loginSuccessful()
        } else {
            print("Spotify auth failed.")
        }
    }

}
