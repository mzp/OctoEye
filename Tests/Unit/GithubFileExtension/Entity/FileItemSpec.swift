//
//  FileItemSpec.swift
//  Tests
//
//  Created by mzp on 2017/07/07.
//  Copyright © 2017 mzp. All rights reserved.
//

import Nimble
import Quick

internal class FileItemSpec: QuickSpec {
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

        var subject: GithubObjectItem {
            get {
                return FileItem(
                    entryObject: entry,
                    parentItemIdentifier: NSFileProviderItemIdentifier("parent")
                ).build()
            }
        }

        describe("static fields") {
            beforeEach {
                entry = self.make()
            }
            it("has copied fields") {
                expect(subject.itemIdentifier) == NSFileProviderItemIdentifier("gitobject.mzp.OctoEye.oid")
                expect(subject.parentItemIdentifier) == NSFileProviderItemIdentifier("parent")
                expect(subject.owner) == "mzp"
                expect(subject.repositoryName) == "OctoEye"
                expect(subject.oid) == "oid"
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
