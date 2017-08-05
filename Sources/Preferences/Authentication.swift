//
//  Authentication.swift
//  OctoEye
//
//  Created by mzp on 2017/07/09.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation

internal let kSuiteName: String = "group.jp.mzp.OctoEye"

internal class Authentication {
    class var accessToken: String? {
        get {
            return UserDefaults(suiteName: kSuiteName)?.value(forKey: "github.accessToken") as? String
        }
        set {
            UserDefaults(suiteName: kSuiteName)?.setValue(newValue, forKey: "github.accessToken")
        }
    }
}
