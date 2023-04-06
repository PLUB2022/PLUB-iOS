//
//  SubCategoryListResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Foundation

/// 상세 카테고리 리스트를 조회할 때 사용되는 응답 모델
struct SubCategoryListResponse: Codable {
  let categories: [SubCategory]
  
  enum CodingKeys: String, CodingKey {
    case categories
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    categories = try values.decodeIfPresent([SubCategory].self, forKey: .categories) ?? []
  }
}
