//
//  TodolistRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/28.
//

import Alamofire

enum TodolistRouter {
  case inquireAllTodolist(Int, Int)
}

extension TodolistRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .inquireAllTodolist:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireAllTodolist(let plubbingID, _):
      return "/plubbings/\(plubbingID)/timeline"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireAllTodolist(_, let cursorID):
      return .query(["cursorId": cursorID])
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireAllTodolist:
      return .withAccessToken
    }
  }
}
