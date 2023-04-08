//
//  BookmarkAllResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/16.
//

import Foundation

struct BookmarkAllResponse: Codable {
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

struct CategoryContent: Codable {
  let plubbingID: Int
  let title: String
  let introduce: String
  let name: String
  let days: [String]
  let mainImage: String
  let address: String
  let roadAddress: String
  let placeName: String
  let placePositionX: Double
  let placePositionY: Double
  let remainAccountNum: Int
  let time: String
  let curAccountNum: Int
  let isBookmarked: Bool
  let views: Int
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
    case title, introduce, name, days, mainImage, address, roadAddress, placeName, placePositionX, placePositionY, remainAccountNum, time, curAccountNum, isBookmarked, views
  }
}

