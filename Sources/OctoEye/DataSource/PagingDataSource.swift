//
//  PagingDataSource.swift
//  OctoEye
//
//  Created by mzp on 2017/08/11.
//  Copyright © 2017 mzp. All rights reserved.
//

import ReactiveSwift
import Result
import UIKit

internal enum PagingEvent {
    case loading
    case completed
}
internal protocol PagingDataSource: UITableViewDataSource {
    var reactive: Signal<PagingEvent, AnyError> { get }
    subscript(index: Int) -> RepositoryObject { get }
    func invokePaging()
}

extension PagingDataSource {

}
