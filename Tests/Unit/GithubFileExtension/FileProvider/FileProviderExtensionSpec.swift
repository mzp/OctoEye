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
import Result

// swiftlint:disable force_try
internal class FileProviderExtensionSpec: QuickSpec {
    func make(name: String, parent: FileItemIdentifier) -> GithubObjectItem {
        let owner = OwnerObject(login: "mzp")
        let repository = RepositoryObject(owner: owner, name: "OctoEye")
        let object = BlobObject(byteSize: 42)
        return GithubObjectItem(
            entryObject: EntryObject(
                repository: repository,
                oid: "oid",
                name: name,
                type: "blob",
                object: object),
            // swiftlint:disable:next force_unwrapping
            parent: parent)!
    }

    // swiftlint:disable:next function_body_length
    override func spec() {
        describe("URL") {
            var subject: FileProviderExtension {
                let response: String! = fixture(name: "content", ofType: "txt")
                let github = GithubClient(
                    token: "-",
                    httpRequest: MockHttpRequest(response: response))
                return FileProviderExtension(github: github)
            }
            var url: URL!
            beforeEach {
                let parent = FileItemIdentifier.repository(owner: "mzp", name: "OctoEye")
                try! FileItemStore().append(parent: parent, entries: [
                    "foo": self.make(name: "foo", parent: parent)
                ])
                let identifier = FileItemIdentifier.entry(owner: "mzp", name: "OctoEye", oid: "_", path: ["foo"])
                url = subject.urlForItem(withPersistentIdentifier: identifier.identifer)
            }

            it("returns flat url") {
                expect(url?.path).to(endWith("foo"))
            }

            it("extract identifier from url") {
                // swiftlint:disable force_unwrapping
                let identifier = subject.persistentIdentifierForItem(at: url!)
                expect(identifier) == FileItemIdentifier.entry(
                    owner: "mzp",
                    name: "OctoEye",
                    oid: "_",
                    path: ["foo"]
                ).identifer
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
                expect(content) == "Content of the blob\n"
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
                    items = self.run(subject, FileItemIdentifier.repository(owner: "mzp", name: "LoveLiver").identifer)
                }
                it("enumarates top level items") {
                    expect(items).to(haveCount(2))
                    expect(items?[0].filename) == ".gitignore.show-extension"
                    expect(items?[1].filename) == "LICENSE.show-extension"
                }
                it("stores") {
                    let store = FileItemStore()
                    let stored = store[.entry(
                        owner: "mzp",
                        name: "LoveLiver",
                        oid: "oid",
                        path: [".gitignore"]
                    )]
                    expect(stored).toNot(beNil())
                }
            }
            context("tree object") {
                beforeEach {
                    response = fixture(name: "treeObject", ofType: "json")
                    items = self.run(subject, FileItemIdentifier.entry(
                        owner: "mzp",
                        name: "LoveLiver",
                        oid: "oid",
                        path: ["sample"]
                    ).identifer)
                }
                it("enumarates top level items") {
                    expect(items).to(haveCount(2))
                    expect(items?[0].filename) == "livephoto"
                    expect(items?[1].filename) == "original"
                }
                it("stores to realm db") {
                    let store = FileItemStore()
                    let stored = store[.entry(
                        owner: "mzp",
                        name: "LoveLiver",
                        oid: "oid",
                        path: ["sample", "livephoto"]
                    )]
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
