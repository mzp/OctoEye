//
//  Mock.swift
//  OctoEye
//
//  Created by mzp on 2017/08/02.
//  Copyright © 2017 mzp. All rights reserved.
//
import UIKit

internal class Mock {
    static func setup() {
        if ProcessInfo.processInfo.arguments.contains("setAccessToken") {
            Authentication.accessToken = "mock-access-token"
        }
        if ProcessInfo.processInfo.arguments.contains("clearAccessToken") {
            Authentication.accessToken = nil
        }
    }

    static func httpResponse() -> String {
        return ProcessInfo.processInfo.environment["httpResponse"] ?? ""
    }

    static var enabled: Bool {
        return ProcessInfo.processInfo.arguments.contains("setAccessToken")
    }
}
