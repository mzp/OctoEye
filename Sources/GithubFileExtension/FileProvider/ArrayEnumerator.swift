//
//  FileProviderEnumerator.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider

internal class ArrayEnumerator: NSObject, NSFileProviderEnumerator {
    private let items: [NSFileProviderItemProtocol]

    init(items: [NSFileProviderItemProtocol]) {
        self.items = items
        super.init()
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        observer.didEnumerate(items)
        observer.finishEnumerating(upTo: nil)
    }

    func invalidate() {
    }
}
