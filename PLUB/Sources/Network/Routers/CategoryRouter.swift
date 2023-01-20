//
//  CategoryRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Alamofire

enum CategoryRouter {
  case inquireMainCategoryList
  case inquireAll
  case inquireSubCategoryList(Int)
}

extension CategoryRouter: Router {
  var method: HTTPMethod {
    return .get
  }
  
  var path: String {
    switch self {
    case .inquireMainCategoryList:
      return "/categories"
    case .inquireAll:
      return "/categories/all"
    case .inquireSubCategoryList(let categoryId):
      return "/categories/\(categoryId)/sub"
    }
  }
  
  var parameters: ParameterType {
    return .plain
  }
  
  var headers: HeaderType {
    return .default
  }
}
