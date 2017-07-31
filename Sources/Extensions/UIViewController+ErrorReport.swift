//
//  AlertController.swift
//  OctoEye
//
//  Created by mzp on 2017/07/31.
//  Copyright © 2017 mzp. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentError(title: String, error: Swift.Error) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: title,
                message: error.localizedDescription,
                preferredStyle: .alert)
            let close = UIAlertAction(title: "Close", style: UIAlertActionStyle.default) { _ in
            }
            alertController.addAction(close)
            self.present(alertController, animated: true) {}
        }
    }
}
