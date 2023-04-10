//
//  MyMeetingResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/01.
//

import Foundation

/// 내 모임 조회 시 응답받는 모델
struct MyMeetingResponse: Codable {
  let myPlubbing: [MyPlubbing]
  
  enum CodingKeys: String, CodingKey {
    case myPlubbing = "plubbings"
  }
}

struct MyPlubbing: Codable {
  
  /// 플러빙 고유 Identifier
  let plubbingID: Int
  
  /// 모임 이름
  let name: String
  
  /// 모임 목표
  let goal: String
  
  /// 모임 대표 이미지
  let mainImage: String?
  
  /// 모임 만남 날짜
  ///
  /// ["MON", "TUE", "WED", "ALL"]와 같이 대문자 형식의 영문명 앞 세 글자만을 사용합니다.
  let days: [Day]
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
    case name, goal, mainImage, days
  }
}
