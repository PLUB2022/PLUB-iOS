//
//  EditMeetingRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/09.
//

import Foundation

struct EditMeetingRequest: Codable {
  /// 요일
  var days: [String]
  
  /// 온/오프라인
  var onOff: OnOff
  
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
    onOff = .on
    peopleNumber = 0
  }
}

extension EditMeetingRequest {
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
