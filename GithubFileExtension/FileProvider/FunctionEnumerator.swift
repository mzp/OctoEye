//
//  GraphqlEnumerator.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider
import GraphQLicious

internal class FunctionEnumerator: NSObject, NSFileProviderEnumerator {
    typealias ItemSource = (@escaping ([GithubObjectItem]) -> Void) -> Void
    private let enumerate: ItemSource

    init(enumerate : @escaping ItemSource) {
        self.enumerate = enumerate
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAtPage page: Data) {
        enumerate { items in
            observer.didEnumerate(items)
            observer.finishEnumerating(upToPage: nil)
        }
    }

    func invalidate() {
    }
}
