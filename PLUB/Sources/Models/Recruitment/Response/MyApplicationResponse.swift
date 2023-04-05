//
//  MyApplicationResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/02.
//

import Foundation

/// 내 지원서 조회 응답 모델
struct MyApplicationResponse: Codable {
  
  /// 지원 날짜
  ///
  /// `yyyy-MM-dd hh:mm:ss`형태로 값을 내려받습니다.
  let date: String
  
  /// 플러빙 정보
  let plubbingInfo: PlubbingInfo
  
  /// 질문에 대한 응답 리스트
  let answers: [Answer]
  
  enum CodingKeys: String, CodingKey {
    case plubbingInfo, answers
    case date = "recruitDate"
  }
}

/// 플러빙 정보 모델
struct PlubbingInfo: Codable {
  
  /// 플러빙 ID
  let plubbingID: Int
  
  /// 플러빙 이름
  let name: String
  
  /// 플러빙 모임 요일 리스트
  let days: [String]
  
  /// 플러빙 모임 주소
  let address: String?
  
  /// 플러빙 모임 도로명 주소
  let roadAddress: String?
  
  /// 플러빙 모임 장소명
  let placeName: String?
  
  /// 플러빙 목표
  let goal: String
  
  /// 플러빙 모임 시간
  ///
  /// `hh:mm`형태로 받습니다.
  let time: String
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
    case name, days, address, roadAddress, placeName, goal, time
  }
}
