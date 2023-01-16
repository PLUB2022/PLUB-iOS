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
}

extension AuthRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .socialLogin, .signUpPLUB:
      return .post
    }
  }
  
  var path: String {
    switch self {
    case .socialLogin:
      return "/auth/login"
    case .signUpPLUB:
      return "/auth/signup"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .socialLogin(model):
      return .body(model)
    case let .signUpPLUB(model):
      return .body(model)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .socialLogin, .signUpPLUB:
      return .default
    }
  }
}
