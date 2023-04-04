//
//  InquireInterestResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/29.
//

import Foundation

struct InquireInterestResponse: Codable {
  let accountID: Int
  let categoryIDs: [Int]
  
  enum CodingKeys: String, CodingKey {
    case accountID = "accountId"
    case categoryIDs = "categoryId"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    accountID = try values.decodeIfPresent(Int.self, forKey: .accountID) ?? 0
    categoryIDs = try values.decodeIfPresent([Int].self, forKey: .categoryIDs) ?? []
  }
}
