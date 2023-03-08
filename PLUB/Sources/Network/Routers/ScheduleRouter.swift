//
//  ScheduleRouter.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/19.
//

import Alamofire

enum ScheduleRouter {
  case createSchedule(Int, CreateScheduleRequest)
  case inquireScheduleList(Int, Int?)
}

extension ScheduleRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .createSchedule:
      return .post
    case .inquireScheduleList:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .createSchedule(let plubbingID, _):
      return "/plubbings/\(plubbingID)/calendar"
    case .inquireScheduleList(let plubbingID, _):
      return "/plubbings/\(plubbingID)/calendar"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .createSchedule(_, let model):
      return .body(model)
    case .inquireScheduleList(_, let cursorID):
      guard let cursorID = cursorID else { return .plain }
      return .query(["cursorId": cursorID])
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .createSchedule, .inquireScheduleList :
      return .withAccessToken
    }
  }
}

