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
  
  // MARK: - User Options
  
  /// 최초 실행 여부를 확인하는 변수
  @UserDefaultsWrapper<Bool>(key: "isLaunchedBefore")
  private(set) var isLaunchedBefore
  
  // MARK: - PLUB Token
  
  @KeyChainWrapper<String>(key: "signToken")
  private(set) var signToken
  
  @KeyChainWrapper<String>(key: "accessToken")
  private(set) var accessToken
  
  @KeyChainWrapper<String>(key: "refreshToken")
  private(set) var refreshToken
  
  @KeyChainWrapper<String>(key: "fcmToken")
  private(set) var fcmToken
  
  // MARK: - Social Login Type
  
  @UserDefaultsWrapper<SocialType>(key: "socialType")
  private(set) var socialType
  
  var hasAccessToken: Bool { return accessToken != nil }
  var hasRefreshToken: Bool { return refreshToken != nil }
  
  // MARK: - Recent Search KeywordList
  
  @UserDefaultsWrapper<[String]>(key: "recentKeywordList")
  private(set) var recentKeywordList
  
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
  
  /// 플럽 푸시 알림에 필요한 `firebase cloud messaging Token`을 세팅합니다.
  func set(fcmToken: String) {
    self.fcmToken = fcmToken
  }
  
  /// 소셜로그인 타입을 세팅합니다.
  /// - Parameter socialType: 소셜로그인 타입(애플, 구글, 카카오)
  func set(socialType: SocialType) {
    self.socialType = socialType
  }
  
  /// 최초 실행 여부를 세팅합니다.
  func set(isLaunchedBefore: Bool) {
    self.isLaunchedBefore = isLaunchedBefore
  }
  
  /// 유저의 정보를 전부 초기화합니다.
  func clearUserInformations() {
    accessToken = nil
    refreshToken = nil
    signToken = nil
    fcmToken = nil
    socialType = nil
  }
  
  /// 가지고 있는 `refresh token`을 가지고 새로운 `access token`과 `refresh token`을 발급받습니다.
  func reissuanceAccessToken() -> Observable<Void> {
    return AuthService.shared.reissuanceAccessToken()
      .map { tokenData in
        self.updatePLUBToken(accessToken: tokenData.accessToken, refreshToken: tokenData.refreshToken)
      }
  }
  
  /// 최근 검색어목록에 키워드를 추가합니다
  /// - Parameter keyword: 검색한 키워드
  func addKeyword(keyword: String) {
    let recentKeywordList = recentKeywordList ?? []
    var filterList = recentKeywordList.filter { $0 != keyword }
    filterList.insert(keyword, at: 0)
    if filterList.count > 10 {
      _ = filterList.popLast()
      self.recentKeywordList = filterList
    } else {
      self.recentKeywordList = filterList
    }
  }
  
  /// 최근 검색어목록에 특정 인덱스에 위치한 키워드를 삭제합니다
  /// - Parameter index: 삭제하고자하는 키워드의 위치
  func removeKeyword(index: Int) {
    guard var recentKeywordList = recentKeywordList,
          (0..<recentKeywordList.count) ~= index else { return }
    recentKeywordList.remove(at: index)
    self.recentKeywordList = recentKeywordList
  }
  
  /// 최근 검색어목록을 초기화합니다
  func clearKeywordList() {
    self.recentKeywordList?.removeAll()
  }
}

