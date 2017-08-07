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
                tab(title: "Repositories", rootViewController: RepositoriesViewController(), image: "home.png"),
                tab(title: "Preferences", rootViewController: PreferencesViewController(), image: "preference.png")
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

    private func tab(title: String, rootViewController: UIViewController, image: String) -> UIViewController {
        return UINavigationController(rootViewController: rootViewController) ※ { nvc in
            nvc.navigationBar.prefersLargeTitles = true
            nvc.tabBarItem = UITabBarItem(title: title,
                                          image: UIImage(named: image),
                                          selectedImage: UIImage(named: "selected \(image)"))
        }
    }
}
