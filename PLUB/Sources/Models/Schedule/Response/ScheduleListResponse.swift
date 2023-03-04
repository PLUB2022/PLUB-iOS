//
//  ScheduleListResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/24.
//

import Foundation

struct ScheduleListResponse: Codable {
  let scheduleList: ScheduleList
  
  enum CodingKeys: String, CodingKey {
    case scheduleList = "calendarList"
  }
}

struct ScheduleList: Codable {
  let totalPages: Int
  let totalSchedules: Int
  let last: Bool
  let schedules: [Schedule]
  
  enum CodingKeys: String, CodingKey {
    case totalPages, last
    case totalSchedules = "totalElements"
    case schedules = "content"
  }
}

struct Schedule: Codable {
  let scheduleID: Int
  let title: String
  let memo: String
  let startDay: String
  let endDay: String
  let startTime: String
  let endTime: String
  let isAllDay: Bool
  let address: String?
  let roadAddress: String?
  let placeName: String?
  let participantList: ParticipantList?
  
  enum CodingKeys: String, CodingKey {
    case title, memo, startTime, endTime, isAllDay, address, roadAddress, placeName
    case scheduleID = "calendarId"
    case startDay = "staredAt"
    case endDay = "endedAt"
    case participantList = "calendarAttendList"
  }
}

struct ParticipantList: Codable {
  let participants: [Participant]
  
  enum CodingKeys: String, CodingKey {
    case participants = "calendarAttendList"
  }
}

struct Participant: Codable {
  let scheduleAttendID: Int
  let nickname: String
  let profileImage: String
  let attendStatus: String
  
  enum CodingKeys: String, CodingKey {
    case nickname, profileImage
    case scheduleAttendID = "calendarAttendId"
    case attendStatus = "AttendStatus"
  }
}