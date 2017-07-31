//
//  File.swift
//  OctoEye
//
//  Created by mzp on 2017/07/31.
//  Copyright © 2017 mzp. All rights reserved.
//

import BrightFutures
import ReactiveSwift

extension SignalProducer {
    init(_ future : @escaping @autoclosure () -> Future<Value, Error>) {
        self.init { (observer, _)  in
            future()
                .onSuccess { observer.send(value: $0) }
                .onFailure { observer.send(error: $0) }
                .onComplete { _ in observer.sendCompleted() }
        }
    }
}
