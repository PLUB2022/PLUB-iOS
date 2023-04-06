//
//  RequestBookmarkResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/29.
//

import Foundation

/// 북마크 등록 요청 모델
struct RequestBookmarkResponse: Codable, Equatable {
  
  /// 플러빙 ID
  let plubbingID: Int
  
  /// 북마크 처리 여부
  ///
  /// 북마크를 등록하려면 `true`, 북마크를 해제하려면 `false`로 처리합니다.
  let isBookmarked: Bool
  
  enum CodingKeys: String, CodingKey {
    case plubbingID = "plubbingId"
    case isBookmarked
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    plubbingID = try values.decodeIfPresent(Int.self, forKey: .plubbingID) ?? -1
    isBookmarked = try values.decodeIfPresent(Bool.self, forKey: .isBookmarked) ?? false
  }
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.plubbingID == rhs.plubbingID && lhs.isBookmarked == rhs.isBookmarked
  }
}
