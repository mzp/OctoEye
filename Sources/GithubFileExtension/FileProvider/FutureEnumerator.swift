//
//  FutureEnumerator.swift
//  OctoEye
//
//  Created by mzp on 2017/07/08.
//  Copyright © 2017 mzp. All rights reserved.
//

import BrightFutures
import FileProvider
import Result

internal class FutureEnumerator<E: Error>: NSObject, NSFileProviderEnumerator {
    private let future: Future<[NSFileProviderItemProtocol], E>

    init(future: Future<[NSFileProviderItemProtocol], E>) {
        self.future = future
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        future.onSuccess {
            observer.didEnumerate($0)
            observer.finishEnumerating(upTo: nil)
        }
    }

    func invalidate() {
    }
}
