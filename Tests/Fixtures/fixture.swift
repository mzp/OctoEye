//
//  fixture.swift
//  Tests
//
//  Created by mzp on 2017/07/08.
//  Copyright © 2017 mzp. All rights reserved.
//
import Foundation

public func fixture(name: String, ofType: String) -> String! {
    guard let url =
        Bundle.main.url(forResource: "PlugIns/Tests.xctest/\(name)", withExtension: ofType) ??
        Bundle.main.url(forResource: "PlugIns/UITest.xctest/\(name)", withExtension: ofType) ??
        Bundle.main.url(forResource: "PlugIns/Snapshot.xctest/\(name)", withExtension: ofType)
    else {
        return nil
    }
    guard let data = try? Data(contentsOf: url) else {
        return nil
    }
    return String(data: data, encoding: .utf8)
}
