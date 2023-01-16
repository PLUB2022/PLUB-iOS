//
//  UserManager.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/15.
//

import Foundation

final class UserManager {
  
  // MARK: - Properties
  
  static let shared = UserManager()
  
  // MARK: - PLUB Token
  
  @KeyChainWrapper<String>(key: "signToken")
  private(set) var signToken
  
  @KeyChainWrapper<String>(key: "accessToken")
  private(set) var accessToken
  
  @KeyChainWrapper<String>(key: "refreshToken")
  private(set) var refreshToken
  
  // MARK: - Social Login Type
  
  @UserDefaultsWrapper<Bool>(key: "socialType")
  private(set) var isAppleLogin
  
  var hasAccessToken: Bool { return accessToken != nil }
  var hasRefreshToken: Bool { return refreshToken != nil }
  var isAppleLoginned: Bool { isAppleLogin! }
  
  // MARK: - Initialization
  
  private init() { }
}

extension UserManager {
  
  /// PLUB의 accessToken과 refreshToken을 업데이트합니다.
  /// - Parameters:
  ///   - accessToken: 새로운 accessToken
  ///   - refreshToken: 새로운 refreshToken
  func updatePLUBToken(accessToken: String, refreshToken: String) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
  
  /// 플럽 회원가입에 필요한 `SignToken`을 세팅합니다.
  func set(signToken: String) {
    self.signToken = signToken
  }
  
  /// 소셜로그인 타입을 세팅합니다.
  /// - Parameter socialType: 소셜로그인 타입(애플, 구글, 카카오)
  func set(socialType: SignInType) {
    isAppleLogin = socialType == .apple ? true : false
  }
}

