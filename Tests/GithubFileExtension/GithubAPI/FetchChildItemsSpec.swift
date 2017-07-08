//
//  FetchChildItemsSpec.swift
//  Tests
//
//  Created by mzp on 2017/07/07.
//  Copyright © 2017 mzp. All rights reserved.
//

import JetToTheFuture
import Nimble
import Quick
import Result

internal class FetchChildItemsSpec: QuickSpec {
    override func spec() {
        let github = GithubClient(token: "-", httpRequest: MockHttpRequest(response: response))
        let entries = forcedFuture { _ in
            FetchChildItems(github: github).call(owner: "mzp", name: "LoveLiver", oid: "-")
        }.value

        describe("entries") {
            it("have all element") {
                expect(entries).to(haveCount(2))
            }

            it("contains entry") {
                expect(entries?[0].oid) == "7a3bac85882e6635f2513f7137de7b1296df70e2"
                expect(entries?[1].oid) == "d7453ad78c8055d2bdd4973c7cee17f60060126d"
            }
        }
    }

    private let response: String = """
{
  "data": {
    "repository": {
      "object": {
        "entries": [
          {
            "oid": "7a3bac85882e6635f2513f7137de7b1296df70e2",
            "name": "livephoto",
            "type": "tree",
            "object": {},
            "repository": {
              "owner": {
                "login": "mzp"
              },
              "name": "LoveLiver"
            }
          },
          {
            "oid": "d7453ad78c8055d2bdd4973c7cee17f60060126d",
            "name": "original",
            "type": "tree",
            "object": {},
            "repository": {
              "owner": {
                "login": "mzp"
              },
              "name": "LoveLiver"
            }
          }
        ]
      }
    }
  }
}
"""
}
