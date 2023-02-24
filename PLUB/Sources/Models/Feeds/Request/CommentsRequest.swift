//
//  CommentsRequest.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/24.
//

import Foundation

struct CommentsRequest: Codable {
  
  /// 댓글 내용
  let content: String
  
  /// 상위 댓글, 대댓글 작성시 필요합니다. 만약 일반 댓글의 경우 nil로 처리하면 됩니다.
  let parentCommentID: Int?
  
  enum CodingKeys: String, CodingKey {
    case content
    case parentCommentID = "parentCommentId"
  }
}
