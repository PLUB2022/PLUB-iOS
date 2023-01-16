//
//  UserManager.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/15.
//

import Foundation

import RxSwift

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
  
  @UserDefaultsWrapper<SignInType>(key: "loginType")
  private(set) var loginnedType
  
  var hasAccessToken: Bool { return accessToken != nil }
  var hasRefreshToken: Bool { return refreshToken != nil }
  
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
    loginnedType = socialType
  }
  
  /// 유저의 정보를 전부 초기화합니다.
  func clearUserInformations() {
    accessToken = nil
    refreshToken = nil
    signToken = nil
    loginnedType = nil
  }
  
  /// 가지고 있는 refreshtoken을 가지고 새로운 accesstoken과 refreshtoken을 발급받습니다.
  func reissuanceAccessToken() -> Observable<Bool> {
    return AuthService.shared.reissuanceAccessToken()
      .map { result in
        switch result {
        case .success(let tokenModel):
          guard let accessToken = tokenModel.data?.accessToken,
                let refreshToken = tokenModel.data?.refreshToken else {
            return false // 토큰이 존재하지 않음
          }
          self.updatePLUBToken(accessToken: accessToken, refreshToken: refreshToken)
          return true // 토큰 갱신 성공
        default:
          return false // 에러
        }
      }
  }
}

