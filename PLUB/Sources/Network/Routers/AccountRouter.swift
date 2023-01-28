//
//  AccountRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/21.
//

import Alamofire

enum AccountRouter {
  case validateNickname(String)
  case inquireInterest
}

extension AccountRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .validateNickname, .inquireInterest:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case let .validateNickname(nickname):
      return "/accounts/check/nickname/\(nickname)"
    case .inquireInterest:
      return "/accounts/me/interest"
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .validateNickname:
      return .default
    case .inquireInterest:
      return .withAccessToken
    }
  }
}
