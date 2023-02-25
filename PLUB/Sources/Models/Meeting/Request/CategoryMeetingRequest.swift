//
//  CategoryMeetingRequest.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/26.
//

import Foundation

struct CategoryMeetingRequest: Codable {
  let days: [String]
  let subCategoryID: [Int]
  let accountNum: Int
  
  enum CodingKeys: String, CodingKey {
    case days, accountNum
    case subCategoryID = "subCategoryId"
  }
}
