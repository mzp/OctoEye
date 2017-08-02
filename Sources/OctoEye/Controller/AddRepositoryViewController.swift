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
    typealias PagingSignal = Signal<String?, AnyError>
    private let fetchRepositories: FetchRepositories? =
        GithubClient.shared.map {
            FetchRepositories(github: $0)
        }
    private let indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var repositories: [RepositoryObject] = []
    private var cursor: FetchRepositories.Cursor?
    private var pagingObserver: PagingSignal.Observer?
    let added: Signal<RepositoryObject, NoError>
    private let addedObserver: Signal<RepositoryObject, NoError>.Observer

    init() {
        let (signal, observer) = Signal<RepositoryObject, NoError>.pipe()
        self.added = signal
        self.addedObserver = observer
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

        let (signal, observer) = PagingSignal.pipe()
        self.pagingObserver = observer
        signal
            .skipRepeats { $0 == $1 }
            .flatMap(FlattenStrategy.concat) { cursor in
                return SignalProducer(fetchRepositories.call(after: cursor)).withIndicator(indicator: self.indicator)
            }
            .observeResult { result in
                switch result {
                case .success((let repositories, let cursor)):
                    self.cursor = cursor
                    self.repositories.append(contentsOf: repositories)
                    self.tableView.reloadData()
                case .failure(let error):
                    self.presentError(title: "cannot fetch repositories", error: error)
                }
            }
        pagingObserver?.send(value: cursor)
    }

    // MARK: - ScrollVeiw
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.bounds.size.height) {
            pagingObserver?.send(value: cursor)
        }
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
        addedObserver.send(value: repositories[indexPath.row])
        addedObserver.sendCompleted()
        navigationController?.popViewController(animated: true)
    }
}
