//
//  SocialType.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/05.
//

import Foundation

/// 소셜 로그인 타입
enum SocialType: String, Codable {
  
  /// 구글
  case google = "GOOGLE"
  
  /// 카카오
  case kakao = "KAKAO"
  
  /// 애플
  case apple = "APPLE"
}
