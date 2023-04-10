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
  case fetchArchiveDetails(plubbingID: Int, archiveID: Int)
  case updateArchive(plubbingID: Int, archiveID: Int, model: CreateArchiveRequest)
  case deleteArchive(plubbingID: Int, archiveID: Int)
}

extension ArchiveRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .createArchive:
      return .post
    case .fetchArchives, .fetchArchiveDetails:
      return .get
    case .updateArchive:
      return .put
    case .deleteArchive:
      return .delete
    }
  }
  
  var path: String {
    switch self {
    case .createArchive(let plubbingID, _),
         .fetchArchives(let plubbingID, _):
      return "/plubbings/\(plubbingID)/archives"
    case .fetchArchiveDetails(let plubbingID, let archiveID),
         .updateArchive(let plubbingID, let archiveID, _),
         .deleteArchive(let plubbingID, let archiveID):
      return "/plubbings/\(plubbingID)/archives/\(archiveID)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .createArchive(_, let model):
      return .body(model)
    case .fetchArchives(_, let cursorID):
      return .query(["cursorId": cursorID])
    case .updateArchive(_, _, let model):
      return .body(model)
    default:
      return .plain
    }
  }
  
  var headers: HeaderType {
    return .withAccessToken
  }
}
