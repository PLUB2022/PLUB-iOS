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
    
    categories = try values.decodeIfPresent([Category].self, forKey: .categories) ?? []
  }
}

struct Category: Codable {
  let id: Int
  let name: String
  let icon: String
  var subCategories: [SubCategory]
}

struct SubCategory: Codable {
  let id: Int
  let name: String
  let categoryName: String
  let parentId: String
  var isSelected: Bool
  
  enum CodingKeys: String, CodingKey {
    case id, name, categoryName, parentId, isSelected
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
    name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    categoryName = try values.decodeIfPresent(String.self, forKey: .categoryName) ?? ""
    parentId = try values.decodeIfPresent(String.self, forKey: .parentId) ?? ""
    isSelected = try values.decodeIfPresent(Bool.self, forKey: .isSelected) ?? false
  }
}
