//
//  InquireInterestResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/29.
//

import Foundation

/// 관심사 조회 응답 모델
struct InquireInterestResponse: Codable {
  /// 계정 ID, 지금은 사용하지 않습니다.
  @available(*, deprecated)
  let accountID: Int
  /// 조회한 카테고리 ID 내역
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
