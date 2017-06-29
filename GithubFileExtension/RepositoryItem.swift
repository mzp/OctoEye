//
//  FileProviderItem.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider

class RepositoryItem: NSObject, NSFileProviderItem {
    private let owner: String
    private let name: String

    init(owner: String, name: String) {
        self.owner = owner
        self.name = name
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier("repository.\(owner).\(name)")
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier.rootContainer
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        return .allowsAll
    }
    
    var filename: String {
        return "\(owner)/\(name)"
    }
    
    var typeIdentifier: String {
        return "public.folder"
    }
    
}
