//
//  BoardsResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/23.
//

import Foundation

/// 게시글 응답 모델
/// 게시글을 생성할 때 사용됩니다.
struct BoardsResponse: Codable {
  
  /// 게시글 고유 Identifier
  let feedID: Int
  
  enum CodingKeys: String, CodingKey {
    case feedID = "feedId"
  }
}
