//
//  FileProviderItem.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/07/02.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import FileProvider
import RealmSwift

class GithubObjectItem: Object, NSFileProviderItem {
    @objc dynamic var itemIdentifier = NSFileProviderItemIdentifier("")
    @objc dynamic var parentItemIdentifier = NSFileProviderItemIdentifier("")
    @objc dynamic var filename = ""
    @objc dynamic var typeIdentifier = ""

    @objc dynamic var owner = ""
    @objc dynamic var repositoryName = ""
    @objc dynamic var oid = ""

    override static func primaryKey() -> String? {
        return "itemIdentifier"
    }
}
