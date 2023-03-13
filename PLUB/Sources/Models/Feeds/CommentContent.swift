//
//  CommentContent.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/27.
//

import Foundation

/// 댓글 타입
enum CommentType: String, Codable {
  
  /// 일반 댓글
  case normal = "COMMENT"
  
  /// 답글
  case reply = "REPLY"
}

/// 댓글 정보 모델
struct CommentContent: Codable {
  
  /// 댓글 ID
  let commentID: Int
  
  /// 댓글 내용
  let content: String
  
  /// 프로필 이미지 URL
  let profileImageURL: String?
  
  /// 닉네임
  let nickname: String
  
  /// 댓글 작성 날짜
  let postDate: String
  
  /// 댓글 작성자 여부
  let isCommentAuthor: Bool
  
  /// 게시글 작성자 여부
  let isFeedAuthor: Bool
  
  /// 작성 타입
  let type: CommentType
  
  /// 답글일 경우 본 댓글의 ID
  let parentCommentID: Int?
  
  /// 답글일 경우 본 댓글 계정의 닉네임
  let parentCommentNickname: String?
  
  /// 하나의 댓글 계층 표현 방식
  let groupID: Int
  
  enum CodingKeys: String, CodingKey {
    case content
    case nickname
    case isCommentAuthor
    case isFeedAuthor
    case parentCommentNickname
    case commentID = "commentId"
    case profileImageURL = "profileImage"
    case postDate = "createdAt"
    case type = "commentType"
    case parentCommentID = "parentCommentId"
    case groupID = "groupId"
  }
  
  private let identifier = UUID()
}

extension CommentContent: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
}
