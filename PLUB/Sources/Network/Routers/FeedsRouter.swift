// 
//  FeedsRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Alamofire

enum FeedsRouter {
  case createBoard(plubID: Int, model: BoardsRequest)
  case fetchBoards(plubID: Int, page: Int)
  case fetchClipboards(plubID: Int)
  case fetchFeedDetails(plubID: Int, feedID: Int)
  case updateFeed(plubID: Int, feedID: Int, model: BoardsRequest)
  case deleteFeed(plubID: Int, feedID: Int)
  case pinFeed(plubID: Int, feedID: Int)
}

extension FeedsRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .createBoard:
      return .post
    case .updateFeed, .pinFeed:
      return .put
    case .deleteFeed:
      return .delete
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
    case .fetchFeedDetails(let plubID, let feedID),
         .updateFeed(let plubID, let feedID, _),
         .deleteFeed(let plubID, let feedID):
      return "/\(prefixPath)/\(plubID)/feeds/\(feedID)"
    case .pinFeed(let plubID, let feedID):
      return "/\(prefixPath)/\(plubID)/feeds/\(feedID)/pin"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .createBoard(_, let model):
      return .body(model)
    case .fetchBoards(_, let page):
      return .query(["page": page])
    case .updateFeed(_, _, let model):
      return .body(model)
    case .fetchClipboards, .fetchFeedDetails, .deleteFeed, .pinFeed:
      return .plain
    }
  }
  
  var headers: HeaderType {
    return .withAccessToken
  }
}
