//
//  MainCategoryListResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Foundation

/// 큰 범주의 카테고리 목록을 조회할 때 사용되는 응답 모델
struct MainCategoryListResponse: Codable {
  let categories: [MainCategory]
  
  enum CodingKeys: String, CodingKey {
    case categories
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    categories = try values.decodeIfPresent([MainCategory].self, forKey: .categories) ?? []
  }
}

struct MainCategory: Codable {
  let id: Int
  let name: String
  let icon: String
}
