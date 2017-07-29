//
//  PreferencesViewController.swift
//  OctoEye
//
//  Created by mzp on 2017/07/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import Ikemen
import UIKit

internal class PreferencesViewController: UITableViewController {
    init() {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: nil) ※ {
            $0.textLabel?.text = "Logout"
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Preferences.accessToken = nil
    }
}
