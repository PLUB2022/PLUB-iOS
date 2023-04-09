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
  case attendSchedule(Int, Int, AttendScheduleRequest)
  case inquireScheduleDetail(Int, Int)
}

extension ScheduleRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .createSchedule:
      return .post
    case .inquireScheduleList, .inquireScheduleDetail:
      return .get
    case .attendSchedule:
      return .put
    }
  }
  
  var path: String {
    switch self {
    case .createSchedule(let plubbingID, _),
        .inquireScheduleList(let plubbingID, _):
      return "/plubbings/\(plubbingID)/calendar"
    case .attendSchedule(let plubbingID, let calendarID, _):
      return "/plubbings/\(plubbingID)/calendar/\(calendarID)/attend"
    case .inquireScheduleDetail(let plubbingID, let calendarID):
      return "/plubbings/\(plubbingID)/calendar/\(calendarID)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .createSchedule(_, let model):
      return .body(model)
    case .inquireScheduleList(_, let cursorID):
      guard let cursorID = cursorID else { return .plain }
      return .query(["cursorId": cursorID])
    case .attendSchedule(_, _, let model):
      return .body(model)
    case .inquireScheduleDetail:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .createSchedule, .inquireScheduleList, .attendSchedule, .inquireScheduleDetail:
      return .withAccessToken
    }
  }
}

