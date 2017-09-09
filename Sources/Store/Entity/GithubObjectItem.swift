//
//  FileProviderItem.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/07/02.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider
import UTIKit

internal class GithubObjectItem: NSObject, Codable, NSFileProviderItem {
    let key: String
    let identifier: String
    let parentIdentifier: String
    let filename: String
    let typeIdentifier: String
    let size: Int?
    private let kPlainTextExtensions: [String] = ["", "md"]

    var documentSize: NSNumber? {
        return size.map { NSNumber(value: $0) }
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier(identifier)
    }
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier(parentIdentifier)
    }

    init?(entryObject: EntryObject, parent: FileItemIdentifier) {
        key = entryObject.name
        guard let identifier = parent.join(oid: entryObject.oid, filename: entryObject.name)?.identifer.rawValue else {
            return nil
        }
        self.identifier = identifier
        self.parentIdentifier = parent.identifer.rawValue

        if entryObject.type == "blob" {
             self.filename = "\(entryObject.name).show-extension"
            let filenameExtension = (entryObject.name as NSString).pathExtension
            if kPlainTextExtensions.contains(filenameExtension) {
                self.typeIdentifier =  "public.plain-text"
            } else if let uti = UTI(filenameExtension: filenameExtension) {
                self.typeIdentifier = uti.utiString
            } else {
                self.typeIdentifier = "public.item"
            }
        } else {
            self.filename = entryObject.name
            self.typeIdentifier = "public.folder"
        }
        size = entryObject.object.byteSize
    }
}
