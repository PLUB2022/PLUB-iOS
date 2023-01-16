//
//  AuthService.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/16.
//

import Foundation

import RxCocoa
import RxSwift

class AuthService: BaseService {
  static let shared = AuthService()
  
  private override init() { }
}

extension AuthService {
  func requestAuth(
    socialType: SignInType,
    token: String?,
    authorizationCode: String?
  ) -> Observable<NetworkResult<GeneralResponse<SignInResponse>>> {
    return sendRequest(
      AuthRouter.socialLogin(SignInRequest(accessToken: token, authorizationCode: authorizationCode, socialType: socialType)),
      type: SignInResponse.self
    )
  }
  
  func signUpToPLUB(
    categoryList: [String],
    profileImageLink: String,
    birthday: String,
    gender: String,
    introduce: String,
    nickname: String,
    marketPolicy: Bool,
    personalPolicy: Bool,
    placePolicy: Bool,
    usePolicy: Bool,
    agePolicy: Bool
  ) -> Observable<NetworkResult<GeneralResponse<TokenResponse>>> {
    return sendRequest(
      AuthRouter.signUpPLUB(SignUpRequest(
        signToken: UserManager.shared.signToken!,
        categoryList: categoryList,
        profileImage: profileImageLink,
        birthday: birthday,
        gender: gender,
        introduce: introduce,
        nickname: nickname,
        marketPolicy: marketPolicy,
        personalPolicy: personalPolicy,
        placePolicy: placePolicy,
        usePolicy: usePolicy,
        agePolicy: agePolicy
      )),
      type: TokenResponse.self
    )
  }
  
  func reissuanceAccessToken() -> Observable<NetworkResult<GeneralResponse<TokenResponse>>> {
    return sendRequest(AuthRouter.reissuanceAccessToken, type: TokenResponse.self)
  }
}
