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

internal class GithubAuthorization: NSObject {
    // store as member field to prevent GC remove this before authorization process complete.
    private let oauth: OAuth2Swift
    private let viewController: UIViewController
    private var complete: Future<OAuthSwiftCredential?, OAuthSwiftError>.CompletionCallback?

    init(viewController: UIViewController) {
        self.viewController = viewController
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
            self.complete = complete
            oauth.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: oauth) ※ {
                    $0.delegate = self
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

extension GithubAuthorization: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        complete?(.success(nil))
    }
}
