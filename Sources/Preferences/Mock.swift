//
//  Mock.swift
//  OctoEye
//
//  Created by mzp on 2017/08/02.
//  Copyright © 2017 mzp. All rights reserved.
//
import UIKit

internal class Mock {
    private static var firstResponse: Bool = true

    static func setup() {
        if ProcessInfo.processInfo.arguments.contains("setAccessToken") {
            Authentication.accessToken = "mock-access-token"
        }
        if ProcessInfo.processInfo.arguments.contains("clearAccessToken") {
            Authentication.accessToken = nil
        }
    }

    static func httpResponse() -> String {
        let response: String

        if firstResponse {
            response = ProcessInfo.processInfo.environment["httpResponse"] ?? ""
            firstResponse = false
        } else {
            response = ProcessInfo.processInfo.environment["httpResponse_later"] ??
                ProcessInfo.processInfo.environment["httpResponse"] ??
                ""
        }
        return response
    }

    static var enabled: Bool {
        return ProcessInfo.processInfo.arguments.contains("setAccessToken")
    }
}
