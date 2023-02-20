//
//  ScheduleRouter.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/19.
//

import Alamofire

enum ScheduleRouter {
  case createSchedule(String, CreateScheduleRequest)
}

extension ScheduleRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .createSchedule:
      return .post
    }
  }
  
  var path: String {
    switch self {
    case .createSchedule(let plubbingID, _):
      return "/plubbings/\(plubbingID)/calendar"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .createSchedule(_, let model):
      return .body(model)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .createSchedule:
      return .withAccessToken
    }
  }
}

