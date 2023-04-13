//
//  SignInRequest.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/16.
//

import Foundation

/// 소셜 로그인 요청 모델
struct SignInRequest: Codable {
  
  /// Firebase Cloud Messaging Token
  let fcmToken: String
  
  /// 액세스 토큰(카카오, 애플)
  /// 애플의 경우 identityToken을 해당 값으로 처리해야합니다.
  let accessToken: String?
  
  /// 인가 코드(구글, 애플)
  let authorizationCode: String?
  
  /// 소셜 로그인 타입
  let socialType: SocialType
}
