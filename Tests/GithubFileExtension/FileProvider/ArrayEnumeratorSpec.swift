//
//  ArrayEnumeratorSpec.swift
//  Tests
//
//  Created by mzp on 2017/07/08.
//  Copyright © 2017 mzp. All rights reserved.
//

import Ikemen
import JetToTheFuture
import Nimble
import Quick

internal class ArrayEnumeratorSpec: QuickSpec {
    override func spec() {
        let items: [NSFileProviderItemProtocol] = [
            GithubObjectItem() ※ { $0.itemIdentifier = NSFileProviderItemIdentifier("0") },
            GithubObjectItem() ※ { $0.itemIdentifier = NSFileProviderItemIdentifier("1") }
        ]

        let enumrator = EnumeratorRunner(enumerator: ArrayEnumerator(items: items))

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
