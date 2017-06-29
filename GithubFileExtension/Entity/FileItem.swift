//
//  FileItem.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import FileProvider

class FileItem: NSObject, NSFileProviderItem {
    let parentItemIdentifier: NSFileProviderItemIdentifier
    private let oid: String
    private let name: String
    private let type: String


    init(oid : String, name : String, type : String, parentItemIdentifier : NSFileProviderItemIdentifier) {
        self.oid = oid
        self.name = name
        self.type = type
        self.parentItemIdentifier = parentItemIdentifier
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier("gitobject.\(oid)")
    }

    var capabilities: NSFileProviderItemCapabilities {
        return .allowsAll
    }

    var filename: String {
        return name
    }

    var typeIdentifier: String {
        if type == "blob" {
            return "public.item"
        } else {
            return "public.folder"
        }
    }

}
