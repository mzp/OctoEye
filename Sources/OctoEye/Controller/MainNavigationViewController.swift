//
//  MainNavigationViewController.swift
//  OctoEye
//
//  Created by mzp on 2017/07/31.
//  Copyright © 2017 mzp. All rights reserved.
//

import Ikemen
import UIKit

internal class MainNavigationViewController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)

        setViewControllers(
            [
                tab(title: "Repositories", rootViewController: RepositoriesViewController(), tag: 1),
                tab(title: "Preferences", rootViewController: PreferencesViewController(), tag: 2)
            ],
            animated: false)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func tab(title: String, rootViewController: UIViewController, tag: Int) -> UIViewController {
        return UINavigationController(rootViewController: rootViewController) ※ { nvc in
            nvc.navigationBar.prefersLargeTitles = true
            nvc.tabBarItem = UITabBarItem(title: title, image: nil, tag: tag)
        }
    }
}
