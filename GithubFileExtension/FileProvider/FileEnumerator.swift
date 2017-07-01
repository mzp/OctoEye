//
//  GraphqlEnumerator.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider
import GraphQLicious

class FileEnumerator: NSObject, NSFileProviderEnumerator {
    private let github = GithubClient(token: "f0b36f49b425c2dcac0bdc64305da04db6ff23c0")
    private let owner : String
    private let name : String
    private let parentItemIdentifier: NSFileProviderItemIdentifier

    init(owner: String, name : String, parentItemIdentifier: NSFileProviderItemIdentifier) {
        self.owner = owner
        self.name = name
        self.parentItemIdentifier = parentItemIdentifier
        super.init()
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAtPage page: Data) {
        FetchFileItems(github: github).call(owner: owner, name: name, parentItemIdentifier: parentItemIdentifier) { items in
            observer.didEnumerate(items)
            observer.finishEnumerating(upToPage: nil)
        }
    }

    func invalidate() {
    }
}
