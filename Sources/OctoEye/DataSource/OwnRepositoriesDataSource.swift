//
//  OwnRepositoriesDataSource.swift
//  OctoEye
//
//  Created by mzp on 2017/08/11.
//  Copyright © 2017 mzp. All rights reserved.
//

import BrightFutures
import Ikemen
import ReactiveSwift
import Result

internal class OwnRepositoriesDataSource: NSObject, PagingDataSource {
    let reactive: Signal<PagingEvent, AnyError>
    private let repositories: PagingRepositories = PagingRepositories()

    init(github: GithubClient) {
        self.reactive = repositories.eventSignal
        super.init()

        let fetchRepositories = FetchRepositories(github: github)
        repositories.observe(signal: repositories.cursor) {
            fetchRepositories.call(after: $0)
        }
    }

    // MARK: - table data source
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

    subscript(index: Int) -> RepositoryObject {
        return repositories[index]
    }
}
