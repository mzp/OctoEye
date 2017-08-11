//
//  PagingRepositories.swift
//  Tests
//
//  Created by mzp on 2017/08/11.
//  Copyright © 2017 mzp. All rights reserved.
//

import BrightFutures
import ReactiveSwift
import Result

internal class PagingRepositories {
    typealias Pipe<Value> = (Signal<Value, AnyError>, Signal<Value, AnyError>.Observer)
    private let (cursorSignal, cursorObserver): Pipe<String?> = Signal<String?, AnyError>.pipe()
    let (eventSignal, eventObserver): Pipe<PagingEvent> = Signal<PagingEvent, AnyError>.pipe()

    init() {
    }

    // MARK: - repositories
    private var repositories: [RepositoryObject] = []

    var count: Int {
        return repositories.count
    }

    subscript(index: Int) -> RepositoryObject {
        return repositories[index]
    }

    func clear() {
        repositories = []
    }

    // MARK: - cursor
    private var currentCursor: String?

    var cursor: Signal<String?, AnyError> {
        return cursorSignal.skipRepeats { $0 == $1 }
    }

    func invokePaging() {
        cursorObserver.send(value: currentCursor)
    }

    // MARK: - observe result
    func observe<T>(signal: Signal<T, AnyError>,
                    fetch: @escaping (T) -> Future<([RepositoryObject], String?), AnyError>) {
        signal
            .flatMap(.concat) { value -> SignalProducer<([RepositoryObject], String?), AnyError> in
                self.eventObserver.send(value: .loading)
                return SignalProducer(fetch(value))
            }
            .observeResult { result in
                switch result {
                case .success(let repositories, let cursor):
                    self.currentCursor = cursor
                    self.repositories.append(contentsOf: repositories)
                    self.eventObserver.send(value: .completed)
                case .failure(let error):
                    self.eventObserver.send(error: error)
                }
            }
    }
}
