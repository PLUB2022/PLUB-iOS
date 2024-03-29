//
//  FeedsContent.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import UIKit

/// 게시글 유형
enum PostType: String, Codable {
  
  /// 사진만으로 이루어져 있음
  case photo = "PHOTO"
  
  /// 텍스트만으로 이루어져 있음
  case text = "LINE"
  
  /// 텍스트와 사진으로 이루어져 있음
  case photoAndText = "PHOTO_LINE"
  
  /// 내용과 이미지 값을 가지고 게시글 유형을 설정합니다.
  /// 만약 게시글에 내용과 이미지가 없는 경우 기본값은 `PostType.text`가 됩니다.
  /// - Parameters:
  ///   - content: 게시글의 내용
  ///   - imageLink: 게시글에 들어가있는 이미지
  init(content: String?, imageLink: String?) {
    if let content = content, let imageLink = imageLink,
       !content.isEmpty && !imageLink.isEmpty {
      self = .photoAndText
    } else if let imageLink = imageLink,
              !imageLink.isEmpty {
      self = .photo
    } else {
      self = .text
    }
  }
}

/// 게시판 유형
enum ViewType: String, Codable {
  
  /// 일반적인 게시글을 나타냅니다.
  case normal = "NORMAL"
  
  /// 게시글이 PIN되어있는 경우를 나타냅니다.
  case pin = "PIN"
  
  /// 시스템에 의해 표시되는 게시글을 나타냅니다.
  case system = "SYSTEM"
}

/// 게시글 정보를 담는 모델
struct FeedsContent: Codable {
  
  /// 게시글 Identifier
  let feedID: Int
  
  /// 게시글 유형
  let type: PostType
  
  /// 게시판 유형
  let viewType: ViewType
  
  /// 게시글 제목
  let title: String
  
  /// 게시글 내용
  let content: String?
  
  /// 게시글 이미지
  let feedImageURL: String?
  
  /// 글 작성(수정)시간
  let postDate: String
  
  /// 상단 고정 여부
  /// 만약 해당 값이 `true`라면, viewType은 무조건 `ViewType.pin`값입니다.
  let isPinned: Bool
  
  /// 좋아요 수
  let likeCount: Int
  
  /// 댓글 수
  let commentCount: Int
  
  /// 프로필 이미지 URL
  let profileImageURL: String?
  
  /// 닉네임
  let nickname: String
  
  /// 플럽 모임 ID, 게시글 상세 조회 API에서는 `nil`로 받습니다.
  let plubbingID: Int?
  
  /// 플럽 이름, 게시글 상세 조회 API 요청 시 값을 받습니다. 그 외에는 전부 `nil`로 세팅됩니다.
  let plubbingName: String?
  
  /// 작성자인지 아닌지를 나타냅니다.
  let isAuthor: Bool
  
  /// 호스트인지 아닌지를 나타냅니다.
  let isHost: Bool
  
  /// 유저가 게시글에 좋아요를 눌렀는지 여부를 판단합니다.
  let isLike: Bool?
  
  enum CodingKeys: String, CodingKey {
    case viewType
    case title
    case content
    case likeCount
    case commentCount
    case nickname
    case plubbingName
    case isAuthor
    case isHost
    case isLike
    case feedImageURL = "feedImage"
    case profileImageURL = "profileImage"
    case feedID = "feedId"
    case type = "feedType"
    case postDate = "createdAt"
    case isPinned = "pin"
    case plubbingID = "plubbingId"
  }
  
  private let identifier = UUID()
}

extension FeedsContent: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
}
