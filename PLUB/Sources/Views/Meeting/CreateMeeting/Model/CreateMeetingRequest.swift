//
//  CreateMeetingRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/01.
//

import Foundation

enum OnOff: String, Codable {
  case on = "ON"
  case off = "OFF"
}

struct CreateMeetingRequest: Codable {
  /// 선택한 카테고리 리스트
  var categoryIDs: [Int]
  
  /// 플러빙 타이틀
  var title: String
  
  /// 플러빙 이름
  var name: String
  
  /// 플러빙 목표
  var goal: String
  
  /// 소개
  var introduce: String
  
  /// 메인 이미지
  var mainImage: String?
  
  /// 시간
  var time: String
  
  /// 요일
  var days: [String]
  
  /// 온/오프라인
  var onOff: OnOff
  
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
  
  /// 인원 수
  var peopleNumber: Int
  
  /// 질문 리스트
  var questions: [String]
}

extension CreateMeetingRequest {
  enum CodingKeys: String, CodingKey {
    case categoryIDs = "subCategoryIds"
    case title
    case name
    case goal
    case introduce
    case mainImage
    case time
    case days
    case onOff
    case address
    case roadAddress
    case placeName
    case positionX = "placePositionX"
    case positionY = "placePositionY"
    case peopleNumber = "maxAccountNum"
    case questions
  }
}
