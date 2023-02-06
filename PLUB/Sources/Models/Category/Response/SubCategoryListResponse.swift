//
//  SubCategoryListResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Foundation

struct SubCategoryListResponse: Codable {
  let categories: [SubCategory]
  
  enum CodingKeys: String, CodingKey {
    case categories
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.categories = try values.decodeIfPresent([SubCategory].self, forKey: .categories) ?? []
  }
}
