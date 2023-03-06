//
//  FeedsPaginatedDataResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Foundation

/// 게시글 별 댓글 조회, 게시판 조회에 같은 응답모델이 들어감
struct FeedsPaginatedDataResponse<FeedsModel: Codable>: Codable {
  
  /// 총 데이터 개수
  let totalElements: Int
  
  /// 다음에 보내야할 `Cursor ID`, `isLast`가 `true`인 경우 `nil`값으로 대체됩니다.
  let nextCursorID: Int?
  
  /// 마지막 페이지 여부
  let isLast: Bool
  
  /// 데이터
  let content: [FeedsModel]
  
  enum CodingKeys: String, CodingKey {
    case totalElements
    case content
    case nextCursorID = "nextCursorId"
    case isLast = "last"
  }
}
