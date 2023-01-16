//
//  ReissuanceRequest.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/17.
//

import Foundation

/// 토큰 재발급할 때 사용되는 요청 모델
struct ReissuanceRequest: Encodable {
  
  /// PLUB의 리프레시 토큰
  let refreshToken: String
}
