//
//  ApplyForRecruitmentResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/19.
//

import Foundation

struct ApplyForRecruitmentResponse: Codable {
  let plubbingID: Int
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    plubbingID = try values.decodeIfPresent(Int.self, forKey: .plubbingID) ?? -1
  }
}
