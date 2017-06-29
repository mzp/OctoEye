//
//  GraphqlEnumerator.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider

class FileEnumerator: NSObject, NSFileProviderEnumerator {
    struct Result : Codable {
        struct Entry : Codable {
            let oid : String
            let name : String
            let type : String
        }
        struct Tree : Codable {
            let entries : [Entry]
        }
        struct Target : Codable {
            let tree : Tree
        }
        struct Ref : Codable {
            let target : Target
        }
        struct Repository : Codable {
            let defaultBranchRef : Ref
        }
        let repository : Repository
    }

    private let github = GithubClient(token: "f0b36f49b425c2dcac0bdc64305da04db6ff23c0")
    private let parentItemIdentifier: NSFileProviderItemIdentifier
    private let query : String

    init(owner: String, name : String, parentItemIdentifier: NSFileProviderItemIdentifier) {
        self.parentItemIdentifier = parentItemIdentifier
        self.query = """
        {
            repository(owner: "\(owner)", name: "\(name)") {
                defaultBranchRef {
                    target {
                        ... on Commit {
                            tree {
                                entries {
                                    oid
                                    name
                                    type
                                }
                            }
                        }
                    }
                }
            }
        }
        """
        super.init()
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAtPage page: Data) {
        try! github.query(query) { (result : Result?, error : Error?) in
            if let error = error {
                NSLog("github api error: \(error)")
                return
            }

            let entries = result?.repository.defaultBranchRef.target.tree.entries.map { entry in
                return FileItem(oid: entry.oid, name: entry.name, type: entry.type, parentItemIdentifier: self.parentItemIdentifier)
            }
            observer.didEnumerate(entries ?? [])
            observer.finishEnumerating(upToPage: nil)
        }
    }

    func invalidate() {
    }
}
