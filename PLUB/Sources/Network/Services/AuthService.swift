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
    socialType: SignInType,
    token: String?,
    authorizationCode: String?
  ) -> Observable<NetworkResult<GeneralResponse<SignInResponse>>> {
    return sendRequest(
      AuthRouter.socialLogin(SignInRequest(accessToken: token, authorizationCode: authorizationCode, socialType: socialType)),
      type: SignInResponse.self
    )
  }
  
  func signUpToPLUB(request: SignUpRequest) -> Observable<NetworkResult<GeneralResponse<TokenResponse>>> {
    return sendRequest(AuthRouter.signUpPLUB(request), type: TokenResponse.self)
  }
  
  func reissuanceAccessToken() -> Observable<NetworkResult<GeneralResponse<TokenResponse>>> {
    return sendRequest(AuthRouter.reissuanceAccessToken, type: TokenResponse.self)
  }
  
  func logout() -> Observable<NetworkResult<GeneralResponse<EmptyModel>>> {
    return sendRequest(AuthRouter.logout)
  }
}
