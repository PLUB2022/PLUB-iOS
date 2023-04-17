//
//  ArchiveContent.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/10.
//

import Foundation

/// 아카이브 조회 시 응답받는 모델
struct ArchiveContent: Codable {
  
  /// 아카이브 ID
  ///
  /// 아카이브 상세 조회 API 호출 시 `nil`값으로 대체되며, 그 외에는 전부 값이 존재합니다.
  let archiveID: Int?
  
  /// 아카이브 제목
  let title: String
  
  /// 아카이브 이미지(주소 링크) 리스트
  let images: [String]
  
  /// 이미지 개수
  let imageCount: Int
  
  /// 순서
  let sequence: Int
  
  /// 작성 날짜
  ///
  /// `yyyy-MM-dd`형태로 내려옵니다.
  let postDate: String
  
  /// 아카이브에 접근한 사용자 타입
  ///
  /// 아카이브 상세 조회 API 호출 시 `nil`값으로 대체되며, 그 외에는 전부 값이 존재합니다.
  let accessType: AccessType?
  
  
  enum CodingKeys: String, CodingKey {
    case title
    case images
    case imageCount
    case sequence
    case accessType
    case archiveID = "archiveId"
    case postDate = "createdAt"
  }
  
  private let identifier = UUID()
}

extension ArchiveContent {
  
  /// 사용자 접근 타입
  enum AccessType: String, Codable {
    
    /// 일반 사용자
    case normal
    
    /// 아카이브 작성자
    case author
    
    /// 모임 호스트
    case host
  }
}

extension ArchiveContent: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
}
