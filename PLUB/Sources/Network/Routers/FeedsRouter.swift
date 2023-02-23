// 
//  FeedsRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Alamofire

enum FeedsRouter {
  case fetchBoard(plubID: String, page: Int)
  case fetchClipboard(plubID: String)
}

extension FeedsRouter: Router {
  
  var method: HTTPMethod {
    return .get
  }
  
  var path: String {
    let prefixPath = "plubbings"
    switch self {
    case .fetchBoard(let plubID, _):
      return "/\(prefixPath)/\(plubID)/feeds"
    case .fetchClipboard(let plubID):
      return "/\(prefixPath)/\(plubID)/pins"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .fetchBoard(_, let page):
      return .query(["page": page])
    case .fetchClipboard:
      return .plain
    }
  }
  
  var headers: HeaderType {
    return .withAccessToken
  }
}
