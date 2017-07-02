//
//  FileItem.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import FileProvider
import UTIKit

class FileItem: NSObject, NSFileProviderItem {
    let parentItemIdentifier: NSFileProviderItemIdentifier
    private let entryObject : EntryObject

    init(entryObject : EntryObject, parentItemIdentifier : NSFileProviderItemIdentifier) {
        self.entryObject = entryObject
        self.parentItemIdentifier = parentItemIdentifier
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier(
            [
                "gitobject",
                entryObject.repository.owner.login,
                entryObject.repository.name,
                entryObject.oid
            ].joined(separator: ".")
        )
    }

    var capabilities: NSFileProviderItemCapabilities {
        return .allowsAll
    }

    var filename: String {
        return entryObject.name
    }

    var typeIdentifier: String {
        if entryObject.type == "blob" {
            if let uti = UTI(filenameExtension: (filename as NSString).pathExtension) {
                return uti.utiString
            } else {
                return "public.item"
            }
        } else {
            return "public.folder"
        }
    }

    class func parse(itemIdentifier: NSFileProviderItemIdentifier) -> (String, String, String)? {
        let xs = itemIdentifier.rawValue.components(separatedBy: ".")

        if xs.count == 4 && xs[0] == "gitobject" {
            return (xs[1], xs[2], xs[3])
        } else {
            return nil
        }
    }
}
