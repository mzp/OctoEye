//
//  FileProviderExtension.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider
import RealmSwift

class FileProviderExtension: NSFileProviderExtension {
    // FIXME: make customizable
    private let github = GithubClient(token: "f0b36f49b425c2dcac0bdc64305da04db6ff23c0")
    private let repositories = [
        ("mzp", "LoveLiver"),
        ("banjun", "SwiftBeaker")
    ]

    var fileManager = FileManager()
    
    override init() {
        super.init()
    }
    
    private func findItem(for identifier: NSFileProviderItemIdentifier) -> NSFileProviderItem? {
        guard let realm = try? Realm() else { return nil }
        return realm.object(ofType: GithubObjectItem.self, forPrimaryKey: identifier.rawValue)
    }
    
    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        guard let item = self.findItem(for: identifier) else {
            return nil
        }

        // create URL as flat structure.
        //  <base storage directory>/<item identifier>/<item file name>
        let manager = NSFileProviderManager.default
        let perItemDirectory = manager.documentStorageURL.appendingPathComponent(identifier.rawValue, isDirectory: true)
        
        return perItemDirectory.appendingPathComponent(item.filename, isDirectory:false)
    }
    
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        // resolve the given URL to a persistent identifier using a database
        let pathComponents = url.pathComponents
        
        // exploit the fact that the path structure has been defined as
        // <base storage directory>/<item identifier>/<item file name> above
        assert(pathComponents.count > 2)
        
        return NSFileProviderItemIdentifier(pathComponents[pathComponents.count - 2])
    }
    
    override func startProvidingItem(at url: URL, completionHandler: ((_ error: Error?) -> Void)?) {
        // Should ensure that the actual file is in the position returned by URLForItemWithIdentifier:, then call the completion handler
        
        /* TODO:
         This is one of the main entry points of the file provider. We need to check whether the file already exists on disk,
         whether we know of a more recent version of the file, and implement a policy for these cases. Pseudocode:
         
         if !fileOnDisk {
             downloadRemoteFile()
             callCompletion(downloadErrorOrNil)
         } else if fileIsCurrent {
             callCompletion(nil)
         } else {
             if localFileHasChanges {
                 // in this case, a version of the file is on disk, but we know of a more recent version
                 // we need to implement a strategy to resolve this conflict
                 moveLocalFileAside()
                 scheduleUploadOfLocalFile()
                 downloadRemoteFile()
                 callCompletion(downloadErrorOrNil)
             } else {
                 downloadRemoteFile()
                 callCompletion(downloadErrorOrNil)
             }
         }
         */
        
        completionHandler?(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
    }
    
    
    override func itemChanged(at url: URL) {
        // Called at some point after the file has changed; the provider may then trigger an upload
        
        /* TODO:
         - mark file at <url> as needing an update in the model
         - if there are existing NSURLSessionTasks uploading this file, cancel them
         - create a fresh background NSURLSessionTask and schedule it to upload the current modifications
         - register the NSURLSessionTask with NSFileProviderManager to provide progress updates
         */
    }
    
    override func stopProvidingItem(at url: URL) {
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        // Care should be taken that the corresponding placeholder file stays behind after the content file has been deleted.
        
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        
        // TODO: look up whether the file has local changes
        let fileHasLocalChanges = false
        
        if !fileHasLocalChanges {
            // remove the existing file to free up space
            do {
                _ = try FileManager.default.removeItem(at: url)
            } catch {
                // Handle error
            }
            
            // write out a placeholder to facilitate future property lookups
            self.providePlaceholder(at: url, completionHandler: { error in
                // TODO: handle any error, do any necessary cleanup
            })
        }
    }
    
    // MARK: - Actions
    
    /* TODO: implement the actions for items here
     each of the actions follows the same pattern:
     - make a note of the change in the local model
     - schedule a server request as a background task to inform the server of the change
     - call the completion block with the modified item in its post-modification state
     */
    
    // MARK: - Enumeration
    
    override func enumerator(forContainerItemIdentifier containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        let maybeEnumerator: NSFileProviderEnumerator? = nil
        if (containerItemIdentifier == NSFileProviderItemIdentifier.rootContainer) {
            let items = repositories.map { (repository : (String, String)) -> RepositoryItem in
                let (owner, name) = repository
                return RepositoryItem(owner: owner, name: name)
            }
            return ArrayEnumerator(items: items)
        } else if (containerItemIdentifier == NSFileProviderItemIdentifier.workingSet) {
            // TODO: instantiate an enumerator for the working set
        } else if (containerItemIdentifier == NSFileProviderItemIdentifier.allDirectories) {
            // TODO: instantiate an enumerator that recursively enumerates all directories
        } else {
            if let (owner, name) = RepositoryItem.parse(itemIdentifier: containerItemIdentifier) {
                return FunctionEnumerator() { f in
                    FetchRootItems(github: self.github)
                        .call(owner: owner, name: name)
                    {
                        switch $0 {
                        case .success(let items):
                            f(self.create(entryObjects: items, parentItemIdentifier: containerItemIdentifier))
                        case .failure(let e):
                            NSLog("error: \(e)")
                        }
                    }
                }
            }

            if let (owner, name, oid) = FileItem.parse(itemIdentifier: containerItemIdentifier) {
                return FunctionEnumerator() { f in
                    FetchChildItems(github: self.github)
                        .call(owner: owner, name: name, oid: oid)
                        {
                            switch $0 {
                            case .success(let items):
                                f(self.create(entryObjects: items, parentItemIdentifier: containerItemIdentifier))
                            case .failure(let e):
                                NSLog("error: \(e)")
                            }
                    }
                }
            }
        }
        guard let enumerator = maybeEnumerator else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:])
        }
        return enumerator
    }

    private func create(entryObjects : [EntryObject], parentItemIdentifier: NSFileProviderItemIdentifier) -> [GithubObjectItem] {
        // Because realm cannot pass object between threads, I create items twice for display and for saving.
        let items = { () in
            return entryObjects.map {
                FileItem(entryObject: $0, parentItemIdentifier: parentItemIdentifier).build()
            }
        }

        DispatchQueue(label: "background").async {
            do {
                let realm = try Realm()
                realm.beginWrite()
                for item in items() {
                    realm.add(item, update: true)
                }
                try realm.commitWrite()
            } catch let e {
                NSLog("Error: \(e)")
                return
            }
        }

        return items()
    }
}
