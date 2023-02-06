//
//  SignUpRequest.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/16.
//

import Foundation

import Then

enum Sex: String, Codable {
  case male = "M"
  case female = "F"
}

struct SignUpRequest: Codable {
  /// sign token
  var signToken: String

  /// 선택한 카테고리 리스트
  var categoryList: [Int]

  /// 등록한 프로필 이미지 사진 링크
  var profileImageLink: String?

  /// 생일
  var birthday: String

  /// 성별
  var sex: Sex

  /// 소개
  var introduction: String

  /// 닉네임
  var nickname: String

  /// 이용약관 및 개인정보 취급 방침
  var termsOfService: Bool
  
  /// 위치 기반 서비스 이용 약관
  var locationBasedService: Bool
  
  /// 만 14세 이상 확인
  var termsAndConditionsForAges: Bool
  
  /// 개인정보 수집 이용 동의
  var privacyPolicy: Bool
  
  /// 마케팅 활용 동의
  var marketing: Bool

  init() {
    signToken = UserManager.shared.signToken!
    categoryList = []
    birthday = ""
    sex = .male
    introduction = ""
    nickname = ""
    termsOfService = false
    locationBasedService = false
    termsAndConditionsForAges = false
    privacyPolicy = false
    marketing = false
  }
}

// MARK: - CodingKeys

extension SignUpRequest {
  enum CodingKeys: String, CodingKey {
    case signToken
    case categoryList
    case profileImageLink = "profileImage"
    case birthday
    case sex = "gender"
    case introduction = "introduce"
    case nickname
    case termsOfService = "usePolicy"
    case locationBasedService = "placePolicy"
    case termsAndConditionsForAges = "agePolicy"
    case privacyPolicy = "personalPolicy"
    case marketing = "marketPolicy"
  }
}

// MARK: - Conform `Then`

extension SignUpRequest: Then { }
