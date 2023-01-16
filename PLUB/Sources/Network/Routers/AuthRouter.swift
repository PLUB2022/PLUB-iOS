//
//  AuthRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/16.
//

import Alamofire

enum AuthRouter {
  case socialLogin(SignInRequest)
}

extension AuthRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .socialLogin:
      return .post
    }
  }
  
  var path: String {
    switch self {
    case .socialLogin:
      return "/auth/login"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case let .socialLogin(model):
      return .body(model)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .socialLogin:
      return .default
    }
  }
}
