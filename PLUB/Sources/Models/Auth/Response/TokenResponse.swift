//
//  TokenResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/17.
//

import Foundation

/// 회원가입 성공 시 받는 토큰 응답 모델
struct TokenResponse: Codable {
  
  /// PLUB의 access token
  let accessToken: String
  
  /// PLUB의 refresh token
  let refreshToken: String
}
