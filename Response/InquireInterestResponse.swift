//
//  InquireInterestResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/29.
//

import Foundation

struct InquireInterestResponse: Codable {
  let accountID: Int
  let categoryID: [Int]
  
  enum CodingKeys: String, CodingKey {
    case accountID = "accountId"
    case categoryID = "categoryId"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.accountID = try values.decodeIfPresent(Int.self, forKey: .accountID) ?? 0
    self.categoryID = try values.decodeIfPresent([Int].self, forKey: .categoryID) ?? []
  }
}
