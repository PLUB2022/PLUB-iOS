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
  let feedID: Int
  
  /// viewType 분기처리를 위한 타입
  let viewType: ViewType
  
  /// 글 작성자
  let author: String
  
  /// 글 작성자 프로필 이미지 링크
  let authorProfileImageLink: String?
  
  /// 작성날짜
  let date: Date
  
  /// 유저가 게시글에 좋아요를 눌렀는지 여부를 판단합니다.
  var isLike: Bool?
  
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
  
  /// 고정 여부
  let isPinned: Bool
  
  /// 작성자인지 여부
  let isAuthor: Bool
  
  /// 호스트인지 여부
  let isHost: Bool
}

extension BoardModel {
  /// 게시글 타입
  var type: PostType {
    if content != nil && imageLink != nil && content!.isEmpty == false && imageLink!.isEmpty == false {
      return .photoAndText
    }
    else if imageLink != nil && imageLink!.isEmpty == false {
      return .photo
    }
    else { return .text }
  }
}

// MARK: - Mapping to BoardModel

extension FeedsContent {
  var toBoardModel: BoardModel {
    let dateFormatter = DateFormatter().then {
      $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
      $0.locale = Locale(identifier: "ko_KR") // locale 설정해야 date 생성 가능
    }
    
    return BoardModel(
      feedID: feedID,
      viewType: viewType,
      author: nickname,
      authorProfileImageLink: profileImageURL,
      date: dateFormatter.date(from: postDate)!,
      isLike: isLike,
      likeCount: likeCount,
      commentCount: commentCount,
      title: title,
      imageLink: feedImageURL,
      content: content
    )
  }
}
