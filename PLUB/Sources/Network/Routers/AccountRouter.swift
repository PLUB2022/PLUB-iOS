//
//  AccountRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/21.
//

import Alamofire

enum AccountRouter {
  case validateNickname(String)
}

extension AccountRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .validateNickname:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case let .validateNickname(nickname):
      return "/accounts/check/nickname/\(nickname)"
    }
  }
}
