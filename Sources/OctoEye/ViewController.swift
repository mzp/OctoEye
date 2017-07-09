//
//  ViewController.swift
//  OctoEye
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import UIKit

internal class ViewController: UIViewController {
    private let authorization: GithubAuthorization = GithubAuthorization()

    override func viewDidLoad() {
        super.viewDidLoad()
        authorization.call().onSuccess { credential in
            NSLog("\(credential.oauthToken)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
