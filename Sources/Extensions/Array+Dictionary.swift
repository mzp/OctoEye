//
//  Array+Dictionary.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/09/09.
//  Copyright © 2017 mzp. All rights reserved.
//

extension Array {
    func toDictionary<Key>(keyBy: (Element) -> Key) -> [Key:Element] {
        var dict: [Key:Element] = [:]
        for element in self {
            dict[keyBy(element)] = element
        }
        return dict
    }
}
