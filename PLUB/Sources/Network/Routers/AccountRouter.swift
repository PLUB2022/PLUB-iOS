//
//  AccountRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/21.
//

import Alamofire

enum AccountRouter {
  case inquireMyInfo
  case validateNickname(String)
  case inquireInterest
  case registerInterest(RegisterInterestRequest)
  case updateMyInfo(MyInfoRequest)
}

extension AccountRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .inquireMyInfo, .validateNickname, .inquireInterest:
      return .get
    case .registerInterest, .updateMyInfo:
      return .post
    }
  }
  
  var path: String {
    switch self {
    case .inquireMyInfo:
      return "/accounts/me"
    case let .validateNickname(nickname):
      return "/accounts/check/nickname/\(nickname)"
    case .inquireInterest:
      return "/accounts/me/interest"
    case .registerInterest:
      return "/accounts/interest"
    case .updateMyInfo:
      return "/accounts/me/profile"
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .validateNickname:
      return .default
    case .inquireMyInfo, .inquireInterest, .registerInterest, .updateMyInfo:
      return .withAccessToken
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireMyInfo, .inquireInterest, .validateNickname:
      return .plain
    case .registerInterest(let request):
      return .body(request)
    case .updateMyInfo(let request):
      return .body(request)
    }
  }
}
