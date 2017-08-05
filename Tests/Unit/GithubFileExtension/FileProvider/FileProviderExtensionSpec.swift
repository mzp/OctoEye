//
//  FileProviderExtensionSpec.swift
//  Tests
//
//  Created by mzp on 2017/07/08.
//  Copyright © 2017 mzp. All rights reserved.
//

import BrightFutures
import FileProvider
import JetToTheFuture
import Nimble
import Quick
import RealmSwift
import Result

// swiftlint:disable force_try
internal class FileProviderExtensionSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        beforeEach {
            // swiftlint:disable force_try
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
            // swiftlint:enable force_try
        }

        describe("URL") {
            var subject: FileProviderExtension {
                let response: String! = fixture(name: "blobObject", ofType: "json")
                let github = GithubClient(
                    token: "-",
                    httpRequest: MockHttpRequest(response: response))
                return FileProviderExtension(github: github)
            }
            var url: URL!
            beforeEach {
                let item = GithubObjectItem()

                // swiftlint:disable:next force_try
                let realm = try! Realm()
                item.itemIdentifier = NSFileProviderItemIdentifier("foo")
                item.filename = "bar"
                // swiftlint:disable:next force_try
                try! realm.write {
                    realm.add(item, update: true)
                }
                url = subject.urlForItem(withPersistentIdentifier: item.itemIdentifier)
            }

            it("returns flat url") {
                expect(url?.path).to(endWith("foo/bar"))
            }

            it("extract identifier from url") {
                // swiftlint:disable force_unwrapping
                let identifier = subject.persistentIdentifierForItem(at: url!)
                expect(identifier) == NSFileProviderItemIdentifier("foo")
            }

            it("create placeholder file") {
                let _: Result<Void, AnyError> = forcedFuture { _ in
                    Future { complete in
                        // swiftlint:disable:next force_unwrapping
                        subject.providePlaceholder(at: url!) { error in
                            if let error = error {
                                complete(.failure(AnyError(error)))
                            } else {
                                complete(.success(()))
                            }
                        }
                    }
                }

                // swiftlint:disable:next force_unwrapping
                expect(FileManager.default.fileExists(atPath: url!.path)).to(beTrue())
            }

            it("provide item") {
                let _: Result<Void, AnyError> = forcedFuture { _ in
                    Future { complete in
                        // swiftlint:disable:next force_unwrapping
                        subject.startProvidingItem(at: url!) { _ in
                            complete(.success(()))
                        }
                    }
                }

                // swiftlint:disable:next force_try force_unwrapping
                let data = try! Data(contentsOf: url!)
                let content = String(data: data, encoding: .utf8)
                expect(content) == "# Xcode (from gitignore.io)"
            }
        }

        describe("Enumeration") {

            var response: String!
            var subject: FileProviderExtension {
                let github = GithubClient(
                    token: "-",
                    httpRequest: MockHttpRequest(response: response))
                return FileProviderExtension(github: github)
            }

            // swiftlint:disable:next force_unwrapping
            var items: [NSFileProviderItemProtocol]!

            context("root") {
                beforeEach {
                    response = fixture(name: "defaultBranch", ofType: "json")
                    WatchingRepositories.shared.clear()
                    WatchingRepositories.shared.append(
                        RepositoryObject(owner: OwnerObject(login: "mzp"), name: "LoveLiver")
                    )
                    WatchingRepositories.shared.append(
                        RepositoryObject(owner: OwnerObject(login: "banjun"), name: "SwiftBeaker")
                    )
                    items = self.run(subject, .rootContainer)
                }
                it("enumarates all repositories") {
                    expect(items).to(haveCount(2))
                    expect(items?[0].filename) == "banjun/SwiftBeaker"
                    expect(items?[1].filename) == "mzp/LoveLiver"
                }
            }
            context("repository root") {
                beforeEach {
                    response = fixture(name: "defaultBranch", ofType: "json")
                    items = self.run(subject, NSFileProviderItemIdentifier("repository.mzp.LoveLiver"))
                }
                it("enumarates top level items") {
                    expect(items).to(haveCount(2))
                    expect(items?[0].filename) == ".gitignore.show-extension"
                    expect(items?[1].filename) == "LICENSE.show-extension"
                }
                it("stores to realm db") {
                    // swiftlint:disable:next force_try
                    let realm = try! Realm()
                    realm.refresh()
                    let stored = realm.object(ofType: GithubObjectItem.self, forPrimaryKey: items?[0].itemIdentifier)
                    expect(stored).toNot(beNil())
                }
            }
            context("tree object") {
                beforeEach {
                    response = fixture(name: "treeObject", ofType: "json")
                    items = self.run(subject, NSFileProviderItemIdentifier("gitobject.mzp.LoveLiver.oid"))
                }
                it("enumarates top level items") {
                    expect(items).to(haveCount(2))
                    expect(items?[0].filename) == "livephoto"
                    expect(items?[1].filename) == "original"
                }
                it("stores to realm db") {
                    // swiftlint:disable:next force_try
                    let realm = try! Realm()
                    realm.refresh()
                    let stored = realm.object(ofType: GithubObjectItem.self, forPrimaryKey: items?[0].itemIdentifier)
                    expect(stored).toNot(beNil())
                }
            }
        }
    }

    func run(_ provider: NSFileProviderExtension,
             _ identifier: NSFileProviderItemIdentifier) -> [NSFileProviderItemProtocol]? {
        return forcedFuture { _ in
            EnumeratorRunner(
                // swiftlint:disable:next force_try
                enumerator: try! provider.enumerator(for: identifier)
            ).run(data: Data())
        }.value
    }
}
