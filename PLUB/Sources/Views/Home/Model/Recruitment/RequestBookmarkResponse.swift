//
//  RequestBookmarkResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/29.
//

import Foundation

struct RequestBookmarkResponse: Codable {
  let plubbingID: Int
  let isBookmarked: Bool
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
    case isBookmarked
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.plubbingID = try values.decodeIfPresent(Int.self, forKey: .plubbingID) ?? -1
    self.isBookmarked = try values.decodeIfPresent(Bool.self, forKey: .isBookmarked) ?? false
  }
}
