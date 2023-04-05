//
//  MyPlubbingResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/13.
//

import Foundation

/// 플러빙 상태
enum PlubbingStatusType: String, CaseIterable {
  
  /// 모집 중인 상태
  case recruiting = "RECRUITING"
  
  /// 대기 중인 상태
  case waiting = "WAITING"
  
  /// 활동 중인 상태
  case active = "ACTIVE"
  
  /// 종료된 상태
  case end = "END"
}

struct MyPlubbingResponse: Codable {
  
  /// 나의 플러빙 상태
  let plubbingStatus: PlubbingStatusType.RawValue
  
  /// 본 `plubbingStatus`값을 따르는 플러빙 리스트
  var plubbings: [MyPagePlubbing]
  
  enum CodingKeys: String, CodingKey {
    case plubbingStatus
    case plubbings
  }
}

struct MyPagePlubbing: Codable {
  
  /// 플러빙 ID
  let plubbingID: Int
  
  /// 플러빙 이름
  let name: String
  
  /// 플러빙 목표
  let goal: String
  
  /// 플러빙 카테고리 아이콘 이미지
  let iconImage: String
  
  /// 내 플러빙 상태
  ///
  /// `HOST`, `GUEST`, `END`값 중 하나로 들어옵니다.
  let myPlubbingStatus: String
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
    case name = "title"
    case goal, iconImage, myPlubbingStatus
  }
}
