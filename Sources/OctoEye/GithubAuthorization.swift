//
//  Authorization.swift
//  OctoEye
//
//  Created by mzp on 2017/07/09.
//  Copyright © 2017 mzp. All rights reserved.
//
import BrightFutures
import Ikemen
import OAuthSwift

internal class GithubAuthorization {
    // Becasue OAuthSwift default url handler is not working on iOS 11,
    // custom version is created here.
    private class OpenURL: OAuthSwiftURLHandlerType {
        func handle(_ url: URL) {
            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                ()
            })
        }
    }

    // store as member field to prevent GC remove this before authorization process complete.
    private let oauth: OAuth2Swift

    init() {
        oauth = OAuth2Swift(
            consumerKey: "dbcd395d464652fb1dc3",
            consumerSecret: "3574b156263a04f59903b9ec418e215d52e8590d",
            authorizeUrl: "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType: "token",
            contentType: "application/json"
        ) ※ {
            $0.authorizeURLHandler = OpenURL()
        }
    }

    func call() -> Future<OAuthSwiftCredential, OAuthSwiftError> {
        return Future { complete in
            oauth.authorize(
                // swiftlint:disable:next force_unwrapping
                withCallbackURL: URL(string: "octo-eye://oauth-callback")!,
                scope: "public:repo", state:"me",
                success: { credential, _, _ in
                    complete(.success(credential))
                },
                failure: { error in
                    complete(.failure(error))
                }
            )
        }
    }

    class func handleCallback(url: URL) {
        OAuth2Swift.handle(url: url)
    }
}
