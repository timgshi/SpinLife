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

    func authViewControllerWithUrl(url: URL) -> UIViewController {
        let safari = SFSafariViewController(url: url)
        safari.delegate = self
        return safari
    }

}
