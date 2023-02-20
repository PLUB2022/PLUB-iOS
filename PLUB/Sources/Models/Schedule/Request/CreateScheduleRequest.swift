//
//  CreateScheduleRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/19.
//

import Then

struct CreateScheduleRequest: Codable {
  /// 제목
  var title: String
  
  /// 메모
  var memo: String
  
  /// 시작일
  var startDay: String
  
  /// 종료일
  var endDay: String
  
  /// 시작 시간
  var startTime: String
  
  /// 종료 시간
  var endTime: String
  
  /// 하루 종일
  var isAllDay: Bool
  
  /// 주소
  var address: String
  
  /// 도로명 주소
  var roadAddress: String
  
  /// 장소 이름
  var placeName: String
  
  /// 알림
  //TODO: 수빈 - 알림 정보 추가
  
  init() {
    title = ""
    memo = ""
    startDay = ""
    startTime = ""
    endDay = ""
    endTime = ""
    isAllDay = false
    address = ""
    roadAddress = ""
    placeName = ""
  }
}

extension CreateScheduleRequest {
  enum CodingKeys: String, CodingKey {
    case title, memo, startTime, endTime, isAllDay, address, roadAddress, placeName
    case startDay = "staredAt"
    case endDay = "endedAt"
  }
}

extension CreateScheduleRequest: Then { }
