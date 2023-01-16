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
  
  func updatePLUBToken(accessToken: String, refreshToken: String) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
  
  func set(signToken: String) {
    self.signToken = signToken
  }
  
  func set(socialType: SignInType) {
    isAppleLogin = socialType == .apple ? true : false
  }
}

