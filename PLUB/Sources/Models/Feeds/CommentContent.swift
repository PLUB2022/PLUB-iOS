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
  var content: String
  
  /// 프로필 이미지 URL
  let profileImageURL: String?
  
  /// 닉네임
  let nickname: String
  
  /// 댓글 작성 날짜
  ///
  /// `2023-03-19 20:24:56`형태의 String 값이 들어옵니다.
  let postDate: String
  
  /// 해당 댓글의 작성자가 자신인지 판단하는 변수입니다.
  ///
  /// 원 게시글 저자인 경우, `isAuthorComment`와 동일한 역할을 하게 됩니다. 하지만 다르게 사용해야함을 명심해주세요.
  /// 본 게시글 저자가 아닌 경우, `isCommentAuthor`은 자신의 댓글에서만 true값으로 응답되지만, `isAuthorComment`은
  /// 현 게시글의 작성자가 단 댓글에서만 `true`값이 나오게 됩니다.
  let isCommentAuthor: Bool
  
  /// 현재 앱으로 로그인한 사용자가 해당 게시물의 저자인지를 나타냅니다. 만약 그렇다면, 모든 댓글 정보에 대한 이 변수값은 `true`로 세팅되고, 아닐 경우 `false`로 세팅됩니다.
  ///
  /// 원 게시글 저자인 경우 다른 사람의 댓글을 삭제 또는 신고할 수 있습니다. 이 기능을 제공하기 위해 해당 변수를 사용합니다.
  let isCurrentUserFeedAuthor: Bool
  
  /// 댓글 작성자가 원 게시글 작성자인지 나타내는 변수입니다.'글쓴이' 마크를 보여주기 위해 사용됩니다.
  let isAuthorComment: Bool
  
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
    case isAuthorComment
    case parentCommentNickname
    case isCurrentUserFeedAuthor = "isFeedAuthor"
    case commentID = "commentId"
    case profileImageURL = "profileImage"
    case postDate = "createdAt"
    case type = "commentType"
    case parentCommentID = "parentCommentId"
    case groupID = "commentGroupId"
  }
  
  private let identifier = UUID()
}

extension CommentContent: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
}

extension CommentContent: Equatable { }
