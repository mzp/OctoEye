//
//  WatchingRepositories.swift
//  OctoEye
//
//  Created by mzp on 2017/08/03.
//  Copyright © 2017 mzp. All rights reserved.
//
import UIKit

internal class WatchingRepositories {
    // MARK: - singleton
    static var shared: WatchingRepositories = WatchingRepositories()
    private init() {}

    // MARK: - serialize
    private var array: [RepositoryObject] {
        get {
            let xs = UserDefaults(suiteName: kSuiteName)?.value(forKey: "watching.repositories") as? [String] ?? []
            return xs.flatMap { RepositoryObject(identifier: $0) }
        }
        set {
            let xs = newValue.map { $0.stringValue }
            UserDefaults(suiteName: kSuiteName)?.setValue(xs, forKey: "watching.repositories")
        }
    }

    private func parse(_ str: String) -> RepositoryObject {
        let xs = str.components(separatedBy: "/")
        return RepositoryObject(owner: OwnerObject(login: xs[0]), name: xs[1])
    }

    // MARK: - array access
    var count: Int {
        return array.count
    }

    func clear() {
        array = []
    }

    func append(_ repository: RepositoryObject) {
        if let index = array.index(where: { repository <= $0 }) {
            let it = array[index]
            if it != repository {
                array.insert(repository, at: index)
            }
        } else {
            array.append(repository)
        }
    }

    // swiftlint:disable:next identifier_name
    func remove(at: Int) {
        array.remove(at: at)
    }

    subscript(index: Int) -> RepositoryObject {
        return array[index]
    }

    func map<T>(_ transform: (RepositoryObject) throws -> T) rethrows -> [T] {
        return try array.map(transform)
    }
}
