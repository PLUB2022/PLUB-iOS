//
//  PaginatedDataResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Foundation

/// 페이징 처리가 들어가는 모델의 경우 해당 모델을 사용합니다.
struct PaginatedDataResponse<Model: Codable>: Codable {
  
  /// 총 데이터 개수
  let totalElements: Int
  
  /// 마지막 페이지 여부
  let isLast: Bool
  
  /// 데이터 콘텐츠
  let content: [Model]
  
  enum CodingKeys: String, CodingKey {
    case totalElements
    case content
    case isLast = "last"
  }
}
