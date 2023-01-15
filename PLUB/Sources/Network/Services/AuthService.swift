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
  ) -> Observable<Result<GeneralResponse<SignInResponse>, PLUBError>> {
    return sendRequest(
      AuthRouter.socialLogin(type: socialType, token: token, authorizationCode: authorizationCode),
      type: SignInResponse.self
    )
  }
}
