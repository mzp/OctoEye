//
//  FileProviderItem.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/07/02.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider
import Foundation
import RealmSwift

internal class GithubObjectItem: Object, NSFileProviderItem {
    @objc dynamic var itemIdentifier: NSFileProviderItemIdentifier = NSFileProviderItemIdentifier("")
    @objc dynamic var parentItemIdentifier: NSFileProviderItemIdentifier = NSFileProviderItemIdentifier("")
    @objc dynamic var filename: String = ""
    @objc dynamic var typeIdentifier: String = ""
    @objc dynamic var size: Int = -1

    @objc dynamic var owner: String = ""
    @objc dynamic var repositoryName: String = ""
    @objc dynamic var oid: String = ""

    // Because realm cannot store NSNumber directroy, we wrap swift's Int
    var documentSize: NSNumber? {
        if size == -1 {
            return nil
        } else {
            return NSNumber(value: size)
        }
    }

    override static func primaryKey() -> String? {
        return "itemIdentifier"
    }
}
