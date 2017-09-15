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
import SafariServices

internal class AuthenticationSession: OAuthSwiftURLHandlerType {
    private var session: SFAuthenticationSession?
    private let cancel: () -> Void
    init(cancel: @escaping () -> Void) {
        self.cancel = cancel
    }

    func handle(_ url: URL) {
        self.session = SFAuthenticationSession(url: url, callbackURLScheme: nil) {  (url, _) in
            guard let url = url else {
                self.cancel()
                return
            }
            OAuth2Swift.handle(url: url)
        }
        session?.start()
    }
}

internal class GithubAuthorization {
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
        )
    }

    func call() -> Future<OAuthSwiftCredential?, OAuthSwiftError> {
        return Future { complete in
            oauth.authorizeURLHandler = AuthenticationSession {
                self.oauth.cancel()
                complete(.success(nil))
            }
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
