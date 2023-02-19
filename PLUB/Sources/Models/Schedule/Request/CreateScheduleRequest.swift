//
//  CreateScheduleRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/19.
//

struct CreateScheduleRequest: Codable {
  /// 제목
  let title: String
  
  /// 메모
  let memo: String
  
  /// 시작일
  let startDay: String
  
  /// 종료일
  let endDay: String
  
  /// 시작 시간
  let startTime: String
  
  /// 종료 시간
  let endTime: String
  
  /// 하루 종일
  let isAllDay: Bool
  
  /// 주소
  let address: String
  
  /// 도로명 주소
  let roadAddress: String
  
  /// 장소 이름
  let placeName: String
  
  /// 알림
  //TODO: 수빈 - 알림 정보 추가
}

extension CreateScheduleRequest {
  enum CodingKeys: String, CodingKey {
    case title, memo, startTime, endTime, isAllDay, address, roadAddress, placeName
    case startDay = "staredAt"
    case endDay = "endedAt"
  }
}
