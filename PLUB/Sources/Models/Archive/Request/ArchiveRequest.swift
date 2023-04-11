//
//  ArchiveRequest.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/10.
//

import Foundation

/// 아카이브 공통 API 요청 모델
struct ArchiveRequest: Codable {
  
  /// 아카이브 제목
  let title: String
  
  /// 아카이브에 들어갈 이미지(주소 링크) 리스트
  let images: [String]
}
