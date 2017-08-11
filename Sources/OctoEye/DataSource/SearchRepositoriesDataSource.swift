//
//  SearchRepositoriesDataSource.swift
//  OctoEye
//
//  Created by mzp on 2017/08/11.
//  Copyright © 2017 mzp. All rights reserved.
//

import Ikemen
import ReactiveSwift
import Result

internal class SearchRepositoriesDataSource: NSObject, PagingDataSource {
    let reactive: Signal<PagingEvent, AnyError>

    private let repositories: PagingRepositories = PagingRepositories()
    private let queryObserver: Signal<String, AnyError>.Observer

    init(github: GithubClient) {
        self.reactive = repositories.eventSignal

        let (querySignal, queryObserver) = Signal<String, AnyError>.pipe()
        self.queryObserver = queryObserver

        super.init()

        let searchRepositories = SearchRepositories(github: github)

        repositories.observe(signal:
            Signal.combineLatest(
                querySignal.throttle(0.5, on: QueueScheduler.main).on(event: { _ in
                    self.repositories.clear()
                }),
                repositories.cursor
        )) { (query, cursor) in
            searchRepositories.call(query: query, after: cursor)
        }
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: nil) ※ {
            let repository = repositories[indexPath.row]
            $0.textLabel?.text = "\(repository.owner.login)/\(repository.name)"
        }
    }

    // MARK: - paging
    func invokePaging() {
        repositories.invokePaging()
    }

    func search(query: String) {
        queryObserver.send(value: query)
    }

    subscript(index: Int) -> RepositoryObject {
        return repositories[index]
    }
}
