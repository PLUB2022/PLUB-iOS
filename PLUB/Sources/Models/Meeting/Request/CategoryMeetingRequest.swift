//
//  CategoryMeetingRequest.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/26.
//

import Foundation

/// 카테고리별 모임 조회를 위한 요청 모델
struct CategoryMeetingRequest: Codable {
  
  /// 필터링할 요일
  ///
  /// ["MON", "TUE", "WED"]와 같이 대문자 형식의 영문명 앞 세 글자만을 사용합니다.
  /// 만약 요일무관인 경우 해당 값은 nil로 처리됩니다.
  let days: [String]?
  
  /// 필터링할 상세 카테고리 Identifier
  ///
  /// 만약 전체 카테고리를 띄우고싶은 경우 해당 값을 nil로 처리하면 됩니다.
  let subCategoryIDs: [Int]?
  
  /// 필터링할 모집 인원 수
  let accountNum: Int
  
  enum CodingKeys: String, CodingKey {
    case days, accountNum
    case subCategoryIDs = "subCategoryId"
  }
}
