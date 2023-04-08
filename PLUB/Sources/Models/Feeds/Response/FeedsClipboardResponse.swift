//
//  FeedsClipboardResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Foundation

/// 클립보드 조회 응답 모델
struct FeedsClipboardResponse: Codable {
  
  /// 클립보드에 들어있는 게시글 목록
  let pinnedFeedList: [FeedsContent]
  
  enum CodingKeys: String, CodingKey {
    case pinnedFeedList = "pinedFeedList"
  }
}
