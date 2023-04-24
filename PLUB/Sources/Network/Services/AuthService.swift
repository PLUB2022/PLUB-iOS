//
//  AuthService.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/16.
//

import Foundation

import RxCocoa
import RxSwift

final class AuthService: BaseService {
  static let shared = AuthService()
  
  private override init() { }
}

extension AuthService {
  func requestAuth(
    socialType: SocialType,
    token: String?,
    authorizationCode: String?
  ) -> PLUBResult<SignInResponse> {
    return sendRequest(
      AuthRouter.socialLogin(
        SignInRequest(
          fcmToken: UserManager.shared.fcmToken ?? "",
          accessToken: token,
          authorizationCode: authorizationCode,
          socialType: socialType
        )
      ),
      type: SignInResponse.self
    )
  }
  
  func signUpToPLUB(request: SignUpRequest) -> Observable<TokenResponse> {
    return sendObservableRequest(AuthRouter.signUpPLUB(request))
  }
  
  func reissuanceAccessToken() -> PLUBResult<TokenResponse> {
    return sendRequest(AuthRouter.reissuanceAccessToken, type: TokenResponse.self)
  }
  
  func logout() -> PLUBResult<EmptyModel> {
    return sendRequest(AuthRouter.logout)
  }
}
