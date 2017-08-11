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

internal class AddRepositoryViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    let added: Signal<RepositoryObject, NoError>
    private let addedObserver: Signal<RepositoryObject, NoError>.Observer

    private let indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    // MARK: - data source
    private lazy var github: GithubClient = {
        // When GithubClient.shared is null, login view must be shown
        // swiftlint:disable:next force_unwrapping
        GithubClient.shared!
    }()

    private lazy var ownDataSource: PagingDataSource = {
        OwnRepositoriesDataSource(github: github)
    }()

    private lazy var searchDataSource: SearchRepositoriesDataSource = {
        SearchRepositoriesDataSource(github: github)
    }()

    private var currentDataSource: PagingDataSource? {
        didSet {
            tableView.dataSource = currentDataSource
            tableView.reloadData()
        }
    }

    // MARK: - ViewController
    init() {
        let (signal, observer) = Signal<RepositoryObject, NoError>.pipe()
        self.added = signal
        self.addedObserver = observer

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add repository"
        indicator.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        indicator.hidesWhenStopped = true
        tableView.tableFooterView = indicator
        navigationItem.searchController = UISearchController(searchResultsController: nil) ※ {
            $0.searchResultsUpdater = self
            $0.delegate = self
            $0.obscuresBackgroundDuringPresentation = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Signal
            .merge([ownDataSource.reactive, searchDataSource.reactive])
            .take(during: self.reactive.lifetime)
            .observeResult {
                switch $0 {
                case .success(.loading):
                    self.startLoadig()
                case .success(.completed):
                    self.stopLoading()
                    self.tableView.reloadData()
                case .failure(let error):
                    self.stopLoading()
                    self.presentError(title: "cannot fetch repositories", error: error)
                }
            }

        currentDataSource = ownDataSource
        currentDataSource?.invokePaging()
    }

    // MARK: - ScrollVeiw
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.bounds.size.height) {
            currentDataSource?.invokePaging()
        }
    }

    // MARK: - TableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let value = currentDataSource?[indexPath.row] {
            addedObserver.send(value: value)
            addedObserver.sendCompleted()
        }
        navigationItem.searchController?.isActive = false
        navigationController?.popViewController(animated: true)
    }

    // MARK: - SearchController
    func updateSearchResults(for searchController: UISearchController) {
        searchDataSource.search(query: searchController.searchBar.text ?? "")
    }

    func willPresentSearchController(_ searchController: UISearchController) {
        currentDataSource = searchDataSource
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        currentDataSource = ownDataSource
    }

    // MARK: - utilities
    private func startLoadig() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }

    private func stopLoading() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
