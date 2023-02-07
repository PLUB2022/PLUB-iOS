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
  
  init(keyword: String, page: Int? = 1, type: String? = "mix", sort: String = "popular") {
    self.keyword = keyword
    self.page = page
    self.type = type
    self.sort = sort
  }
}
