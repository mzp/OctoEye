//
//  FileProviderExtension.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider
import Ikemen
import Result

internal class FileProviderExtension: NSFileProviderExtension {
    private let github: GithubClient?
    private let repositories: WatchingRepositories = WatchingRepositories.shared
    private let fileItemStore: FileItemStore = FileItemStore()

    var fileManager: FileManager = FileManager()

    convenience override init() {
        self.init(github: GithubClient.shared)
    }

    init(github: GithubClient?) {
        self.github = github
        super.init()
    }

    // MARK: - URL

    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        guard let id = FileItemIdentifier.parse(identifier) else {
            return nil
        }
        guard let item = fileItemStore[id] else {
            return nil
        }

        // create URL as flat structure.
        //  <base storage directory>/<item identifier>/<item file name>
        let manager = NSFileProviderManager.default
        let perItemDirectory = manager.documentStorageURL.appendingPathComponent(identifier.rawValue, isDirectory: true)

        return perItemDirectory.appendingPathComponent(item.key, isDirectory:false)
    }

    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        // resolve the given URL to a persistent identifier using a database
        let pathComponents = url.pathComponents

        // exploit the fact that the path structure has been defined as
        // <base storage directory>/<item identifier>/<item file name> above
        assert(pathComponents.count > 2)

        return NSFileProviderItemIdentifier(pathComponents[pathComponents.count - 2])
    }

    // swiftlint:disable:next prohibited_super_call
    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        NSLog("providePlaceholder \(url)")
        do {
            try fileManager.createDirectory(at: url.deletingLastPathComponent(),
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            fileManager.createFile(atPath: url.path, contents: nil, attributes: nil)
            completionHandler(nil)
        } catch let e {
            completionHandler(e)
        }
    }

    override func startProvidingItem(at url: URL, completionHandler: ((_ error: Error?) -> Void)?) {
        guard let github = self.github else {
            return
        }
        // FIXME: skip download when latest content exists on disk
        guard let identifier = persistentIdentifierForItem(at: url) else {
            completionHandler?(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
            return
        }

        switch FileItemIdentifier.parse(identifier) {
            case .some(.entry(owner: let owner, name: let name, let oid, path: _)):
                FetchBlob(github: github)
                    .call(owner: owner, name: name, oid: oid)
                    .onSuccess { data in
                        do {
                            try data.write(to: url)
                            completionHandler?(nil)
                        } catch let e {
                            completionHandler?(e)
                        }
                    }
                    .onFailure { error in
                        NSLog("FetchTextError: \(error)")
                    }
            default:
                ()
        }
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
            self.providePlaceholder(at: url, completionHandler: { _ in
                // TODO: handle any error, do any necessary cleanup
            })
        }
    }

    // MARK: - Enumeration

    // swiftlint:disable:next line_length
    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        guard let github = self.github else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:])
        }

        let identifier = FileItemIdentifier.parse(containerItemIdentifier) ?? .root
        switch identifier {
        case .root:
            let items = repositories.map {
                RepositoryItem(owner: $0.owner.login, name: $0.name)
            }
            return ArrayEnumerator(items: items)
        case .repository(owner: let owner, name: let name):
            let future =
                FetchRootItems(github: github)
                    .call(owner: owner, name: name)
                    .map {
                        $0.flatMap {
                            GithubObjectItem(entryObject: $0, parent: identifier)
                        } ※ {
                            try? self.fileItemStore.append(parent: identifier, entries: $0.toDictionary {
                                $0.key
                            })
                        }
                    }
            return FutureEnumerator(future: future)
        case .entry(owner: let owner, name: let name, oid: let oid, path: _):
            let future =
                FetchChildItems(github: github)
                    .call(owner: owner, name: name, oid: oid)
                    .map {
                        $0.flatMap {
                            GithubObjectItem(entryObject: $0, parent: identifier)
                        } ※ {
                            try? self.fileItemStore.append(parent: identifier, entries: $0.toDictionary {
                                $0.key
                            })
                        }
                    }
            return FutureEnumerator(future: future)
        }
    }
}
