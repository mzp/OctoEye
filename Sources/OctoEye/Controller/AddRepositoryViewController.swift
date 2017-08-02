//
//  AddRepositoryViewController.swift
//  OctoEye
//
//  Created by mzp on 2017/08/01.
//  Copyright © 2017 mzp. All rights reserved.
//

import Ikemen
import ReactiveSwift
import Result
import UIKit

internal class AddRepositoryViewController: UITableViewController {
    private let fetchRepositories: FetchRepositories? =
        GithubClient.shared.map {
            FetchRepositories(github: $0)
        }
    private let indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var repositories: [RepositoryObject] = []

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Add repository"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        indicator.hidesWhenStopped = true
        tableView.tableFooterView = indicator
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let fetchRepositories = self.fetchRepositories else {
            self.presentError(
                title: "must not happen",
                error:  NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
            return
        }

        _ = SignalProducer(fetchRepositories.call())
            .withIndicator(indicator: indicator)
            .on(failed: {
                self.presentError(title: "cannot fetch repositories", error: $0)
            })
            .on(value: { repositories in
                self.repositories = repositories
                self.tableView.reloadData()
            })
            .start()
    }

    // MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: nil) ※ {
            let repository = repositories[indexPath.row]
            $0.textLabel?.text = "\(repository.owner.login)/\(repository.name)"
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
    }
}
