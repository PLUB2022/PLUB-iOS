//
//  AnnouncementContent.swift
//  PLUB
//
//  Created by 홍승현 on 2023/05/17.
//

import Foundation

/// 공지 조회 시 응답받을 모델
struct AnnouncementContent {
  
  /// 공지 고유 Identifier
  let noticeID: Int
  
  /// 공지 제목
  let title: String
  
  /// 공지 내용
  let content: String
  
  /// 작성 날짜
  var postingDate: Date? {
    DateFormatterFactory.dateTime.date(from: postDateString)
  }
  
  /// 접근자가 호스트인지 여부
  let isHost: Bool
  
  private let postDateString: String
  
  // MARK: 아래부터는 `공지 상세 조회`시 받는 프로퍼티
  
  /// 공지 작성자 계정 정보
  let accountInfo: AccountInfo?
  
  /// 좋아요 수
  let likeCount: Int?
  
  /// 댓글 수
  let commentCount: Int?
}

// MARK: - Codable

extension AnnouncementContent: Codable {
  
  enum CodingKeys: String, CodingKey {
    case title
    case content
    case isHost
    case accountInfo
    case likeCount
    case commentCount
    case noticeID = "noticeId"
    case postDateString = "createdAt"
  }
}

//TODO: 승현 - API 연동 후 제거할 예정

extension AnnouncementContent {
  static var mockUp: Self {
    AnnouncementContent(
      noticeID: 0,
      title: "공지입니다.",
      content: "공지 내용입니다.",
      isHost: true,
      postDateString: "2023-03-21 16:36:47",
      accountInfo: nil,
      likeCount: nil,
      commentCount: nil
    )
  }
}
