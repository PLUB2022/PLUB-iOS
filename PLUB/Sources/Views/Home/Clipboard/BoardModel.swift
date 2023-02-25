//
//  BoardModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/25.
//

import Foundation

/// 게시글 모델
struct BoardModel {
  
  let type: PostType
  
  /// 글 작성자
  let author: String
  
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
