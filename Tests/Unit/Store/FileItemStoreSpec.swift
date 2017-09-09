//
//  FileItemStoreSpec.swift
//  Tests
//
//  Created by mzp on 2017/09/09.
//  Copyright © 2017 mzp. All rights reserved.
//

import Nimble
import Quick

// swiftlint:disable function_body_length, force_try
internal class FileItemStoreSPec: QuickSpec {
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

    override func spec() {
         let subject = FileItemStore()

        beforeEach {
            JsonCache<String>.clearAll()
        }

        describe("root") {
            it("returns nothing") {
                expect(subject[.root]).to(beNil())
            }
            it("cannot store anything") {
                expect { try subject.append(parent: .root, entries: [:]) }.notTo(throwAssertion())
            }
        }

        describe("repository") {
            let identifier = FileItemIdentifier.repository(owner: "mzp", name: "OctoEye")
            it("can store children") {
                try! subject.append(parent: identifier, entries: [
                    "foo": self.make(name: "foo", parent: identifier),
                    "bar": self.make(name: "bar", parent: identifier)
                ])

                let result = subject[.entry(owner: "mzp", name: "OctoEye", oid: "_", path: ["foo"])]
                expect(result?.filename) == "foo.show-extension"
            }
        }

        describe("repository") {
            let identifier = FileItemIdentifier.entry(owner: "mzp", name: "OctoEye", oid: "_", path: ["foo"])

            it("returns non-store value") {
                expect(subject[identifier]).to(beNil())
            }
            it("can store children") {
                try! subject.append(parent: identifier, entries: [
                    "bar": self.make(name: "bar", parent: identifier),
                    "baz": self.make(name: "baz", parent: identifier)
                ])

                let result = subject[.entry(owner: "mzp", name: "OctoEye", oid: "_", path: ["foo", "bar"])]
                expect(result?.filename) == "bar.show-extension"
            }
        }
    }
}
