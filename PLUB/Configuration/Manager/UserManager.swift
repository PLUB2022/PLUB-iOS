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
  
  // MARK: - Social Login Token
  
  @KeyChainWrapper<String>(key: "socialAccessToken")
  private(set) var socialAccessToken
  
  // MARK: - PLUB Token
  
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
}

