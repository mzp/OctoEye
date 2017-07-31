//
//  AddRepositoryViewController.swift
//  OctoEye
//
//  Created by mzp on 2017/08/01.
//  Copyright © 2017 mzp. All rights reserved.
//

import Ikemen
import UIKit

internal class AddRepositoryViewController: UITableViewController {
    let repositories: [String] = ["mzp/OctoEye"]

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Add repository"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
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
            $0.textLabel?.text = repositories[indexPath.row]
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
    }
}
