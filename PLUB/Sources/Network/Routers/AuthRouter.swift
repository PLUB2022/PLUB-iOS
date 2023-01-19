//
//  AuthRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/16.
//

import Alamofire

enum AuthRouter {
  case socialLogin(SignInRequest)
  case signUpPLUB(SignUpRequest)
  case reissuanceAccessToken
  case logout
}

extension AuthRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .socialLogin, .signUpPLUB, .reissuanceAccessToken:
      return .post
    case .logout:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .socialLogin:
      return "/auth/login"
    case .signUpPLUB:
      return "/auth/signup"
    case .reissuanceAccessToken:
      return "/auth/reissue"
    case .logout:
      return "/auth/logout"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .socialLogin(model):
      return .body(model)
    case let .signUpPLUB(model):
      return .body(model)
    case .reissuanceAccessToken:
      return .body(ReissuanceRequest(refreshToken: UserManager.shared.refreshToken ?? ""))
    case .logout:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .socialLogin, .signUpPLUB, .reissuanceAccessToken:
      return .default
    case .logout:
      return .withRefreshToken
    }
  }
}
