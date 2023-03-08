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
  case attendSchedule(Int, Int)
}

extension ScheduleRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .createSchedule:
      return .post
    case .inquireScheduleList:
      return .get
    case .attendSchedule:
      return .put
    }
  }
  
  var path: String {
    switch self {
    case .createSchedule(let plubbingID, _),
        .inquireScheduleList(let plubbingID, _),
        .attendSchedule(let plubbingID, _):
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
    case .attendSchedule(_, let calendarID):
      return .query(["calendarId": calendarID])
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .createSchedule, .inquireScheduleList, .attendSchedule:
      return .withAccessToken
    }
  }
}

