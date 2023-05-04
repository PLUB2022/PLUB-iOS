//
//  TodolistRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/28.
//

import Alamofire

enum TodolistRouter {
  case inquireAllTodoTimeline(Int, Int)
  case inquireTodolist(Int, Int)
}

extension TodolistRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .inquireAllTodoTimeline, .inquireTodolist:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireAllTodoTimeline(let plubbingID, _):
      return "/plubbings/\(plubbingID)/timeline"
    case .inquireTodolist(let plubbingID, let timelineID):
      return "/plubbings/\(plubbingID)/timeline/\(timelineID)/todolist"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireAllTodoTimeline(_, let cursorID):
      return .query(["cursorId": cursorID])
    case .inquireTodolist:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireAllTodoTimeline, .inquireTodolist:
      return .withAccessToken
    }
  }
}

