//
//  SignInRequest.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/16.
//

import Foundation

/// 소셜 로그인 타입
enum SocialType: String, Codable {
  
  /// 구글
  case google
  
  /// 카카오
  case kakao
  
  /// 애플
  case apple
}


/// `Plub Backend`에 보낼 소셜 로그인 모델
struct SignInRequest: Codable {
  
  /// 액세스 토큰(카카오, 애플)
  /// 애플의 경우 identityToken을 해당 값으로 전달해야한다.
  let accessToken: String?
  
  /// 인가 코드(구글, 애플)
  let authorizationCode: String?
  
  /// 소셜 로그인 타입
  let socialType: SocialType
}
