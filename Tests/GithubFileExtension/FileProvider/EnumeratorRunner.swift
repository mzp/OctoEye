//
//  FutureEnumerator.swift
//  Tests
//
//  Created by mzp on 2017/07/08.
//  Copyright © 2017 mzp. All rights reserved.
//
import BrightFutures
import Result

internal class EnumeratorRunner {
    class MockObserver: NSObject, NSFileProviderEnumerationObserver {
        private let onEnumerate: ([NSFileProviderItemProtocol]) -> Void

        init(onEnumerate: @escaping ([NSFileProviderItemProtocol]) -> Void) {
            self.onEnumerate = onEnumerate
        }

        func didEnumerate(_ updatedItems: [NSFileProviderItemProtocol]) {
            onEnumerate(updatedItems)
        }

        func finishEnumerating(upToPage nextPage: Data?) {
        }

        func finishEnumeratingWithError(_ error: Error) {
        }
    }

    private let enumerator: NSFileProviderEnumerator

    init(enumerator: NSFileProviderEnumerator) {
        self.enumerator = enumerator
    }

    func run(data: Data) -> Future<[NSFileProviderItemProtocol], NoError> {
        return Future { complete in
            let observer = MockObserver {
                complete(.success($0))
            }
            enumerator.enumerateItems(for: observer, startingAtPage: data)
        }
    }
}
