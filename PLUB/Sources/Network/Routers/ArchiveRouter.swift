// 
//  ArchiveRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/10.
//

import Alamofire

enum ArchiveRouter {
  case createArchive(plubbingID: Int, model: CreateArchiveRequest)
  case fetchArchives(plubbingID: Int, cursorID: Int)
}

extension ArchiveRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .createArchive:
      return .post
    case .fetchArchives:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .createArchive(let plubbingID, _),
         .fetchArchives(let plubbingID, _):
      return "/plubbings/\(plubbingID)/archives"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .createArchive(_, let model):
      return .body(model)
    case .fetchArchives(_, let cursorID):
      return .query(["cursorId": cursorID])
    default:
      return .plain
    }
  }
  
  var headers: HeaderType {
    return .withAccessToken
  }
}
