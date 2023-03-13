//
//  BoardModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/25.
//

import Foundation

/// 게시글 모델
struct BoardModel {
  
  /// 게시글 상세조회위한 피드아이디
  let feedID: String = ""
  
  /// viewType 분기처리를 위한 타입
  let viewType: ViewType = .normal
  
  /// 글 작성자
  let author: String
  
  /// 글 작성자 프로필 이미지 링크
  let authorProfileImageLink: String?
  
  /// 작성날짜
  let date: Date
  
  /// 좋아요 수
  let likeCount: Int
  
  /// 댓글 수
  let commentCount: Int
  
  /// 제목
  let title: String
  
  /// 이미지 링크
  let imageLink: String?
  
  /// 내용
  let content: String?
}

extension BoardModel {
  /// 게시글 타입
  var type: PostType {
    if content != nil && imageLink != nil { return .photoAndText }
    else if imageLink != nil { return .photo }
    else { return .text }
  }
  
}
