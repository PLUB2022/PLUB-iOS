//
//  SearchParameter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/28.
//

import Foundation

struct SearchParameter: Encodable {
  let keyword: String
  let page: Int?
  let type: String?
  let sort: String
}
