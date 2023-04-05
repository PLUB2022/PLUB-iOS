//
//  CreateMeetingResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/01.
//

import Foundation

/// 모임 생성 시 받는 응답 모델
struct CreateMeetingResponse: Codable {
  
  /// 플러빙 ID
  let plubbingID: Int
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
  }
}
