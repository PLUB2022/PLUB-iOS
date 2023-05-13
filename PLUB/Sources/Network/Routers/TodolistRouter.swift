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
  case completeTodolist(Int, Int)
  case cancelCompleteTodolist(Int, Int)
  case proofTodolist(Int, Int, ProofTodolistRequest)
  case likeTodolist(Int, Int)
  case createTodo(Int, CreateTodoRequest)
  case inquireTodolistByDate(Int, String)
}

extension TodolistRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .inquireAllTodoTimeline, .inquireTodolist, .inquireTodolistByDate:
      return .get
    case .completeTodolist, .cancelCompleteTodolist, .likeTodolist:
      return .put
    case .proofTodolist, .createTodo:
      return .post
    }
  }
  
  var path: String {
    switch self {
    case .inquireAllTodoTimeline(let plubbingID, _):
      return "/plubbings/\(plubbingID)/timeline"
    case .inquireTodolist(let plubbingID, let timelineID):
      return "/plubbings/\(plubbingID)/timeline/\(timelineID)/todolist"
    case .completeTodolist(let plubbingID, let todolistID):
      return "/plubbings/\(plubbingID)/todolist/\(todolistID)/complete"
    case .proofTodolist(let plubbingID, let todolistID, _):
      return "/plubbings/\(plubbingID)/todolist/\(todolistID)/proof"
    case .cancelCompleteTodolist(let plubbingID, let todolistID):
      return "/plubbings/\(plubbingID)/todolist/\(todolistID)/cancel"
    case .likeTodolist(let plubbingID, let timelineID):
      return "/plubbings/\(plubbingID)/timeline/\(timelineID)/like"
    case .createTodo(let plubbingID, _):
      return "/plubbings/\(plubbingID)/todolist"
    case .inquireTodolistByDate(let plubbingID, let todoDate):
      return "/plubbings/\(plubbingID)/timeline/\(todoDate)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireAllTodoTimeline(_, let cursorID):
      return .query(["cursorId": cursorID])
    case .inquireTodolist, .completeTodolist, .cancelCompleteTodolist, .likeTodolist, .inquireTodolistByDate:
      return .plain
    case .proofTodolist(_, _, let request):
      return .body(request)
    case .createTodo(_, let request):
      return .body(request)
    }
  }
  
  var headers: HeaderType {
    return .withAccessToken
  }
}

