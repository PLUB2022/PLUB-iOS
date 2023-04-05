//
//  CategoryMeetingResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/20.
//

import Foundation

struct CategoryMeetingResponse: Codable {
  let totalPages: Int
  let totalElements: Int
  let last: Bool
  let content: [Content]
  
  enum CodingKeys: String, CodingKey {
    case totalPages, totalElements, last, content
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    totalPages = try values.decodeIfPresent(Int.self, forKey: .totalPages) ?? 0
    totalElements = try values.decodeIfPresent(Int.self, forKey: .totalElements) ?? 0
    last = try values.decodeIfPresent(Bool.self, forKey: .last) ?? false
    content = try values.decodeIfPresent([Content].self, forKey: .content) ?? []
  }
}

struct Content: Codable {
  
  /// 플러빙 ID
  let plubbingID: Int
  
  /// 플러빙 이름
  let name: String
  
  /// 플러빙 타이틀
  let title: String
  
  /// 플러빙 대표 이미지
  let mainImage: String?
  
  /// 플러빙 소개
  let introduce: String
  
  /// 플러빙 모임 날짜
  ///
  /// `hh:mm`형태로 내려받습니다.
  let time: String
  
  /// 플러빙 모임 요일 리스트
  let days: [String]
  
  /// 플러빙 모임 주소
  let address: String
  
  /// 플러빙 모임 도로명 주소
  let roadAddress: String
  
  /// 플러빙 모임 장소 이름
  let placeName: String
  
  /// 플러빙 모임 위치 중 위도
  let placePositionX: Double
  
  /// 플러빙 모임 위치 중 경도
  let placePositionY: Double
  
  /// 현재 플러빙 참여 인원 수
  let curAccountNum: Int
  
  /// 플러빙에 참여할 수 있는 잔여 인원 수
  let remainAccountNum: Int
  
  /// 북마크 여부
  let isBookmarked: Bool
  
  /// 로그인한 사용자가 실제 플러빙의 호스트인지 여부를 판단합니다.
  let isHost: Bool
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
    case name, title, mainImage, introduce, time, days, address, roadAddress, placeName, placePositionX, placePositionY, curAccountNum, remainAccountNum, isBookmarked, isHost
  }
}
