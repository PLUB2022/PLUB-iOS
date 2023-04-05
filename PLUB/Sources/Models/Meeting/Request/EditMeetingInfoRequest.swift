//
//  EditMeetingInfoRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/09.
//

import Foundation

struct EditMeetingInfoRequest: Codable {
  /// 요일
  var days: [String]
  
  /// 온/오프라인
  var onOff: MeetType
  
  /// 인원 수
  var peopleNumber: Int
  
  /// 주소
  var address: String?
  
  /// 도로명 주소
  var roadAddress: String?
  
  /// 장소 이름
  var placeName: String?
  
  /// x 좌표
  var positionX: Double?
  
  /// y 좌표
  var positionY: Double?
  
  init() {
    days = []
    onOff = .online
    peopleNumber = 0
  }
  
  init(
    days: [String],
    onOff: MeetType,
    peopleNumber: Int,
    address: String? = nil,
    roadAddress: String? = nil,
    placeName: String? = nil,
    positionX: Double? = nil,
    positionY: Double? = nil
  ) {
    self.days = days
    self.onOff = onOff
    self.peopleNumber = peopleNumber
    self.address = address
    self.roadAddress = roadAddress
    self.placeName = placeName
    self.positionX = positionX
    self.positionY = positionY
  }
}

extension EditMeetingInfoRequest {
  enum CodingKeys: String, CodingKey {
    case days
    case onOff
    case address
    case roadAddress
    case placeName
    case positionX = "placePositionX"
    case positionY = "placePositionY"
    case peopleNumber = "maxAccountNum"
  }
}
