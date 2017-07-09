//
//  ViewController.swift
//  OctoEye
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import UIKit

internal class ViewController: UIViewController {
    private let status: UILabel = UILabel()
    private let authorization: GithubAuthorization = GithubAuthorization()

    override func viewDidLoad() {
        super.viewDidLoad()
        status.frame = self.view.frame
        self.view = status
        status.textAlignment = .center
        status.font = UIFont.systemFont(ofSize: 128)

        if Preferences.accessToken != nil {
            status.text = "👍"
        } else {
            authorization.call()
                .onSuccess { credential in
                    Preferences.accessToken = credential.oauthToken
                    DispatchQueue.main.async {
                        self.status.text = "👍"
                    }
                }
                .onFailure { error in
                    NSLog("\(error)")
                    DispatchQueue.main.async {
                        self.status.text = "👎"
                    }
                }
        }
    }
}
