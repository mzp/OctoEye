//
//  AppDelegate.swift
//  OctoEye
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import OAuthSwift
import UIKit

// swiftlint:disable line_length
@UIApplicationMain
internal class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("setAccessToken") {
            Authentication.accessToken = "mock-access-token"
        }
        if ProcessInfo.processInfo.arguments.contains("clearAccessToken") {
            Authentication.accessToken = nil
        }

        window = UIWindow(frame: UIScreen.main.bounds)

        if Authentication.accessToken != nil {
            window?.rootViewController = MainNavigationViewController()
        } else {
            window?.rootViewController = LoginViewController()
        }

        window?.makeKeyAndVisible()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == "oauth-callback" {
            GithubAuthorization.handleCallback(url: url)
        }
        return true
    }
}
// swiftlint:enable line_length
