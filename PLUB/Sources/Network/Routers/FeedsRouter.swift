// 
//  FeedsRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Alamofire

enum FeedsRouter {
  case createBoard(plubID: Int, model: CreateBoardsRequest)
  case fetchBoards(plubID: Int, page: Int)
  case fetchClipboards(plubID: Int)
}

extension FeedsRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .createBoard:
      return .post
    default:
      return .get
    }
  }
  
  var path: String {
    let prefixPath = "plubbings"
    switch self {
    case .fetchBoards(let plubID, _),
         .createBoard(let plubID, _):
      return "/\(prefixPath)/\(plubID)/feeds"
    case .fetchClipboards(let plubID):
      return "/\(prefixPath)/\(plubID)/pins"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .createBoard(_, let model):
      return .body(model)
    case .fetchBoards(_, let page):
      return .query(["page": page])
    case .fetchClipboards:
      return .plain
    }
  }
  
  var headers: HeaderType {
    return .withAccessToken
  }
}
