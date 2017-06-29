//
//  FileProviderItem.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider

class RepositoryItem: NSObject, NSFileProviderItem {
    private let repository: String

    init(repository: String) {
        self.repository = repository
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier("repository.\(repository)")
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier.rootContainer
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        return .allowsAll
    }
    
    var filename: String {
        return repository
    }
    
    var typeIdentifier: String {
        return "public.folder"
    }
    
}
