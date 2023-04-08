//
//  AllCategoryListResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Foundation

/// 카테고리 전체를 조회할 때 사용되는 응답 모델
struct AllCategoryListResponse: Codable {
  let categories: [Category]
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    categories = try values.decodeIfPresent([Category].self, forKey: .categories) ?? []
  }
}

// MARK: - Category

struct Category: Codable {
  
  /// 카테고리 고유 Identifier
  let id: Int
  
  /// 카테고리 이름
  let name: String
  
  /// 카테고리 Icon 이미지 주소
  let icon: String
  
  /// 상세 카테고리 배열
  var subCategories: [SubCategory]
}

// MARK: - SubCategory

struct SubCategory: Codable {
  let id: Int
  let name: String
  let categoryName: String
  let parentID: String
  
  enum CodingKeys: String, CodingKey {
    case id, name, categoryName
    case parentID = "parentId"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
    name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    categoryName = try values.decodeIfPresent(String.self, forKey: .categoryName) ?? ""
    parentID = try values.decodeIfPresent(String.self, forKey: .parentID) ?? ""
  }
}

