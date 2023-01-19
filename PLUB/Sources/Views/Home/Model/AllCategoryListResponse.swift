//
//  AllCategoryListResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Foundation

struct AllCategoryListResponse: Codable {
  let categories: [Category]
  
  enum CodingKeys: String, CodingKey {
    case categories
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.categories = try values.decodeIfPresent([Category].self, forKey: .categories) ?? []
  }
}

struct Category: Codable {
  let id: Int
  let name: String
  let icon: String
  let subCategories: [SubCategory]
}

struct SubCategory: Codable {
  let id: Int
  let name: String
  let categoryName: String
  let parentId: String
}
