//
//  FutureEnumeratorSpec.swift
//  Tests
//
//  Created by mzp on 2017/07/08.
//  Copyright © 2017 mzp. All rights reserved.
//

import BrightFutures
import Ikemen
import JetToTheFuture
import Nimble
import Quick
import Result

internal class FutureEnumeratorSpec: QuickSpec {
    class Item: NSObject, NSFileProviderItem {
        var itemIdentifier: NSFileProviderItemIdentifier = NSFileProviderItemIdentifier(rawValue: "")
        var parentItemIdentifier: NSFileProviderItemIdentifier = NSFileProviderItemIdentifier(rawValue: "")
        var filename: String = ""
        var typeIdentifier: String = ""
    }

    override func spec() {
        let items: [NSFileProviderItemProtocol] = [
            Item() ※ { $0.itemIdentifier = NSFileProviderItemIdentifier("0") },
            Item() ※ { $0.itemIdentifier = NSFileProviderItemIdentifier("1") }
        ]
        let future = Future<[NSFileProviderItemProtocol], NoError>(value: items)

        let enumrator = EnumeratorRunner(enumerator: FutureEnumerator(future: future))

        describe("items") {
            var subject: [NSFileProviderItemProtocol]? {
                return forcedFuture { _ in
                    enumrator.run(data: Data())
                }.value
            }

            it("returns original array") {
                expect(subject).to(haveCount(2))
                expect(subject?[0].itemIdentifier) == NSFileProviderItemIdentifier("0")
                expect(subject?[1].itemIdentifier) == NSFileProviderItemIdentifier("1")
            }
        }
    }
}
