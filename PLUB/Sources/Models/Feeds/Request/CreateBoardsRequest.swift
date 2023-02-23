//
//  CreateBoardsRequest.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/23.
//

import Foundation

struct CreateBoardsRequest: Codable {
  /// 게시글 제목
  let title: String
  
  /// 게시글 내용
  let content: String?
  
  /// 게시글 이미지
  let feedImage: String?
  
  /// 게시글 타입
  private let feedType: PostType
  
  init(title: String, content: String?, feedImage: String?) {
    self.title = title
    self.content = content
    self.feedImage = feedImage
    self.feedType = .init(content: content, imageLink: feedImage)
  }
}
