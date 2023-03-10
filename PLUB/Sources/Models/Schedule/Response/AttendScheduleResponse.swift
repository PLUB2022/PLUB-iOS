//
//  AttendScheduleResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/09.
//

import Foundation

struct AttendScheduleResponse: Codable {
  let calendarAttendID: Int
  let nickname: String
  let profileImage: String
  let attendStatus: String

  enum CodingKeys: String, CodingKey {
    case calendarAttendID = "calendarAttendId"
    case nickname, profileImage
    case attendStatus = "AttendStatus"
  }
}
