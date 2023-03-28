//
//  TodolistRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/28.
//

import Alamofire

enum TodolistRouter {
  case inquireAllTodolist(Int)
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
    case .inquireAllTodolist(let plubbingID):
      return "/plubbings/\(plubbingID)/timeline"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireAllTodolist:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireAllTodolist:
      return .withAccessToken
    }
  }
}

