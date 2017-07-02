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
    let filename: String

    private let owner: String
    private let name: String
    private let oid: String
    private let type: String

    init(owner : String, name : String, oid : String, filename : String, type : String, parentItemIdentifier : NSFileProviderItemIdentifier) {
        self.owner = owner
        self.name = name
        self.oid = oid
        self.filename = filename
        self.type = type
        self.parentItemIdentifier = parentItemIdentifier
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier("gitobject.\(owner).\(name).\(oid)")
    }

    var capabilities: NSFileProviderItemCapabilities {
        return .allowsAll
    }

    var typeIdentifier: String {
        if type == "blob" {
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
