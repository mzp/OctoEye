//
//  FileProviderEnumerator.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider

class ArrayEnumerator: NSObject, NSFileProviderEnumerator {
    private let items : [NSFileProviderItemProtocol]

    init(items: [NSFileProviderItemProtocol]) {
        self.items = items
        super.init()
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAtPage page: Data) {
        observer.didEnumerate(items)
        observer.finishEnumerating(upToPage: nil)
    }

    func invalidate() {
    }
}
