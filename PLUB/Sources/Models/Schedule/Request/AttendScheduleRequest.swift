//
//  AttendScheduleRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/09.
//

import Foundation

enum AttendScheduleType: String {
  case yes = "YES"
  case no = "NO"
}

struct AttendScheduleRequest: Codable {
  let attendStatus: String
  
  enum CodingKeys: String, CodingKey {
    case attendStatus
  }
}
