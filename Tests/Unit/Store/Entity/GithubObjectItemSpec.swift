//
//  GithubObjectItemSpec.swift
//  Tests
//
//  Created by mzp on 2017/07/07.
//  Copyright © 2017 mzp. All rights reserved.
//

import Nimble
import Quick

// swiftlint:disable force_unwrapping
internal class GithubObjectItemSpec: QuickSpec {
    func make(name: String = "README.txt", type: String = "blob") -> EntryObject {
        let owner = OwnerObject(login: "mzp")
        let repository = RepositoryObject(owner: owner, name: "OctoEye")
        let object = BlobObject(byteSize: 42)
        return EntryObject(
            repository: repository,
            oid: "oid",
            name: name,
            type: type,
            object: object)
    }

    // swiftlint:disable:next function_body_length
    override func spec() {
        var entry: EntryObject!
        let parent = FileItemIdentifier.repository(owner: "mzp", name: "OctoEye")

        var subject: GithubObjectItem {
            get {
                return GithubObjectItem(
                    entryObject: entry,
                    parent: parent
                )!
            }
        }

        describe("static fields") {
            beforeEach {
                entry = self.make()
            }
            it("has copied fields") {
                expect(subject.itemIdentifier) == FileItemIdentifier.entry(
                    owner: "mzp",
                    name: "OctoEye",
                    oid: "oid",
                    path: ["README.txt"]
                ).identifer
                expect(subject.parentItemIdentifier) == parent.identifer
                expect(subject.size) == 42
            }
        }

        describe("filename") {
            context("blob") {
                beforeEach {
                    entry = self.make()
                }
                it("has dummy extension") {
                    expect(subject.filename) == "README.txt.show-extension"
                }
            }

            context("tree") {
                beforeEach {
                    entry = self.make(name: "Sources", type: "tree")
                }
                it("has own filename") {
                    expect(subject.filename) == "Sources"
                }
            }
        }

        describe("type") {
            context("tree") {
                beforeEach {
                    entry = self.make(name: "Sources", type: "tree")
                }
                it("has folder type") {
                    expect(subject.typeIdentifier) == "public.folder"
                }
            }
            context("well-known") {
                beforeEach {
                    entry = self.make(name: "README.swift")
                }
                it("has unique type") {
                    expect(subject.typeIdentifier) == "public.swift-source"
                }
            }
            context("maybe text") {
                beforeEach {
                    entry = self.make(name: "README.md")
                }
                it("has text type") {
                    expect(subject.typeIdentifier) == "public.plain-text"
                }
            }
        }
    }
}
