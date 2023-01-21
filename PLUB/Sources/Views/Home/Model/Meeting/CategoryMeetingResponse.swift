//
//  CategoryMeetingResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/20.
//

import Foundation

struct CategoryMeetingResponse: Codable {
  let plubbings: Plubbing?
  let pageable: Pageable?
  let last: Bool
  let totalPages: Int
  let totalElements: Int
  let size: Int
  let number: Int
  let sort: Sort?
  let first: Bool
  let numberOfElements: Int
  let empty: Bool
  
  enum CodingKeys: String, CodingKey {
    case plubbings, pageable, last, totalPages, totalElements, size, number, sort, first, numberOfElements, empty
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.plubbings = try values.decodeIfPresent(Plubbing.self, forKey: .plubbings)
    self.pageable = try values.decodeIfPresent(Pageable.self, forKey: .pageable)
    self.last = try values.decodeIfPresent(Bool.self, forKey: .last) ?? false
    self.totalPages = try values.decodeIfPresent(Int.self, forKey: .totalPages) ?? 0
    self.totalElements = try values.decodeIfPresent(Int.self, forKey: .totalElements) ?? 0
    self.size = try values.decodeIfPresent(Int.self, forKey: .size) ?? 0
    self.number = try values.decodeIfPresent(Int.self, forKey: .number) ?? 0
    self.sort = try values.decodeIfPresent(Sort.self, forKey: .sort)
    self.first = try values.decodeIfPresent(Bool.self, forKey: .first) ?? false
    self.numberOfElements = try values.decodeIfPresent(Int.self, forKey: .numberOfElements) ?? 0
    self.empty = try values.decodeIfPresent(Bool.self, forKey: .empty) ?? false
    
  }
}

struct Plubbing: Codable {
  let content: [Content]
}

struct Content: Codable {
  let plubbingId: Int
  let name: String
  let title: String
  let mainImage: String?
  let introduce: String
  let time: String
  let days: [String]
  let address: String
  let roadAddress: String
  let placeName: String
  let placePositionX: Double
  let placePositionY: Double
  let curAccountNum: Int
  let remainAccountNum: Int
  let isBookmarked: Bool
}

struct Pageable: Codable {
  let sort: Sort
  let offset: Int
  let pageSize: Int
  let pageNumber: Int
  let unpaged: Bool
  let paged: Bool
}

struct Sort: Codable {
  let empty: Bool
  let sorted: Bool
  let unsorted: Bool
}

