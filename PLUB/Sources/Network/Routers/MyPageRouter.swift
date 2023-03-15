//
//  MyPageRouter.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/13.
//

import Alamofire

enum MyPageRouter {
  case inquireMyMeeting(MyPlubbingParameter)
}

extension MyPageRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .inquireMyMeeting:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireMyMeeting:
      return "/plubbings/all/my"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireMyMeeting(let parameter):
      return .query(parameter)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireMyMeeting:
      return .withAccessToken
    }
  }
}

