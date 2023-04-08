//
//  SignInResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/16.
//

import Foundation

/// 소셜로그인 응답 모델
struct SignInResponse: Codable {
  
  /// PLUB의 access token, 이미 존재한 회원인 경우 해당 값을 받아옵니다.
  let accessToken: String?
  
  /// PLUB의 refresh token, 이미 존재한 회원인 경우 해당 값을 받아옵니다.
  let refreshToken: String?
  
  /// 사인 토큰, 신규 회원일 경우 해당 값을 받아옵니다.
  let signToken: String?
}
