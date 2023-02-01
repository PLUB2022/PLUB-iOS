//
//  CreateMeetingResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/01.
//

import Foundation

struct CreateMeetingResponse: Codable {
  
  /// 플러빙 ID
  let plubbingID: String
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
  }
}
