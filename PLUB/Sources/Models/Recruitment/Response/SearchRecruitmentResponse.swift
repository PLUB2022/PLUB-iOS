//
//  SearchRecruitmentResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/28.
//

import Foundation

struct SearchRecruitmentResponse: Codable {
  let totalPages: Int
  let totalElements: Int
  let last: Bool
  let content: [CategoryContent]
  
  enum CodingKeys: String, CodingKey {
    case totalPages, totalElements, last, content
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    totalPages = try values.decodeIfPresent(Int.self, forKey: .totalPages) ?? 0
    totalElements = try values.decodeIfPresent(Int.self, forKey: .totalElements) ?? 0
    last = try values.decodeIfPresent(Bool.self, forKey: .last) ?? false
    content = try values.decodeIfPresent([CategoryContent].self, forKey: .content) ?? []
  }
}

