//
//  LoginViewController.swift
//  OctoEye
//
//  Created by mzp on 2017/07/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import ReactiveCocoa
import ReactiveSwift
import UIKit

internal class LoginViewController: UIViewController {
    private let loginButton: UIButton = UIButton(type: .system)
    private lazy var authorization: GithubAuthorization = {
        GithubAuthorization(viewController: self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        self.view.addSubview(loginButton)

        loginButton.accessibilityIdentifier = "login"
        loginButton.setTitle("🔐", for: .normal)
        loginButton.layer.cornerRadius = 2.0
        loginButton.layer.borderColor = UIColor.gray.cgColor
        loginButton.layer.borderWidth = 1.0
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        for anchor in [
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 250),
            loginButton.heightAnchor.constraint(equalToConstant: 44)
        ] {
            anchor.isActive = true
        }

        loginButton.reactive
            .mapControlEvents(.touchDown) { _ in () }
            .flatMap(.concat) { _ in SignalProducer(self.authorization.call()) }
            .observeResult { result in
                switch result {
                case .success(let credential):
                    guard let oauthToken = credential?.oauthToken else {
                        return
                    }
                    Authentication.accessToken = oauthToken
                    DispatchQueue.main.async {
                        self.present(MainNavigationViewController(), animated: true) {}
                    }
                case .failure(let error):
                    self.presentError(title: "Github authorization error", error: error)
                }
            }
    }
}
