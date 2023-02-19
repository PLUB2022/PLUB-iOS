//
//  CreateScheduleResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/19.
//

import Foundation

struct CreateScheduleResponse: Codable {
  
  /// 플러빙 ID
  let calendarID: Int
  
  enum CodingKeys: String, CodingKey {
    case calendarID = "calendarId"
  }
}
