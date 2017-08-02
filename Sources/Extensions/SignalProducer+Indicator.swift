//
//  SignalProducer+Indicator.swift
//  OctoEye
//
//  Created by mzp on 2017/08/02.
//  Copyright © 2017 mzp. All rights reserved.
//
import ReactiveSwift
import UIKit

extension SignalProducer {
    func withIndicator(indicator: UIActivityIndicatorView? = nil) -> SignalProducer<Value, Error> {
        return self.on(
            starting: {
                DispatchQueue.main.async {
                    indicator?.startAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
            },
            terminated: {
                DispatchQueue.main.async {
                    indicator?.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        )
    }
}
