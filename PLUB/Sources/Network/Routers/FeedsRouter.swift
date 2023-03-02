// 
//  FeedsRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Alamofire

enum FeedsRouter {
  // === 게시판, 게시글 파트 ===
  case createBoard(plubID: Int, model: BoardsRequest)
  case fetchBoards(plubID: Int, page: Int)
  case fetchClipboards(plubID: Int)
  case fetchFeedDetails(plubID: Int, feedID: Int)
  case updateFeed(plubID: Int, feedID: Int, model: BoardsRequest)
  case deleteFeed(plubID: Int, feedID: Int)
  case pinFeed(plubID: Int, feedID: Int)
  case likeFeed(plubID: Int, feedID: Int)
  
  // === 댓글 파트 ===
  case createComment(plubID: Int, feedID: Int, model: CommentsRequest)
}

extension FeedsRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .createBoard, .createComment:
      return .post
    case .updateFeed, .pinFeed, .likeFeed:
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
    case .likeFeed(let plubID, let feedID):
      return "/\(prefixPath)/\(plubID)/feeds/\(feedID)/like"
    case .createComment(let plubID, let feedID, _):
      return "/\(prefixPath)/\(plubID)/feeds/\(feedID)/comments"
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
    case .fetchClipboards, .fetchFeedDetails, .deleteFeed, .pinFeed, .likeFeed:
      return .plain
    case .createComment(_, _, let model):
      return .body(model)
    }
  }
  
  var headers: HeaderType {
    return .withAccessToken
  }
}