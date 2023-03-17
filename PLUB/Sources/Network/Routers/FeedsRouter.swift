// 
//  FeedsRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Alamofire

enum FeedsRouter {
  // === 게시판, 게시글 파트 ===
  case createBoard(plubbingID: Int, model: BoardsRequest)
  case fetchBoards(plubbingID: Int, cursorID: Int)
  case fetchClipboards(plubbingID: Int)
  case fetchFeedDetails(plubbingID: Int, feedID: Int)
  case updateFeed(plubbingID: Int, feedID: Int, model: BoardsRequest)
  case deleteFeed(plubbingID: Int, feedID: Int)
  case pinFeed(plubbingID: Int, feedID: Int)
  case likeFeed(plubbingID: Int, feedID: Int)
  
  // === 댓글 파트 ===
  case fetchComments(plubbingID: Int, feedID: Int, cursorID: Int)
  case createComment(plubbingID: Int, feedID: Int, model: CommentsRequest)
  case updateComment(plubbingID: Int, feedID: Int, commentID: Int, content: String)
  case deleteComment(plubbingID: Int, feedID: Int, commentID: Int)
}

extension FeedsRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .createBoard, .createComment:
      return .post
    case .updateFeed, .pinFeed, .likeFeed, .updateComment:
      return .put
    case .deleteFeed, .deleteComment:
      return .delete
    default:
      return .get
    }
  }
  
  var path: String {
    let prefixPath = "plubbings"
    switch self {
    case .fetchBoards(let plubbingID, _),
         .createBoard(let plubbingID, _):
      return "/\(prefixPath)/\(plubbingID)/feeds"
    case .fetchClipboards(let plubbingID):
      return "/\(prefixPath)/\(plubbingID)/pins"
    case .fetchFeedDetails(let plubbingID, let feedID),
         .updateFeed(let plubbingID, let feedID, _),
         .deleteFeed(let plubbingID, let feedID):
      return "/\(prefixPath)/\(plubbingID)/feeds/\(feedID)"
    case .pinFeed(let plubbingID, let feedID):
      return "/\(prefixPath)/\(plubbingID)/feeds/\(feedID)/pin"
    case .likeFeed(let plubbingID, let feedID):
      return "/\(prefixPath)/\(plubbingID)/feeds/\(feedID)/like"
      
    case .fetchComments(let plubbingID, let feedID, _),
         .createComment(let plubbingID, let feedID, _):
      return "/\(prefixPath)/\(plubbingID)/feeds/\(feedID)/comments"
    case .updateComment(let plubbingID, let feedID, let commentID, _),
         .deleteComment(let plubbingID, let feedID, let commentID):
      return "/\(prefixPath)/\(plubbingID)/feeds/\(feedID)/comments/\(commentID)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .createBoard(_, let model):
      return .body(model)
    case .fetchBoards(_, let cursorID),
         .fetchComments(_, _, let cursorID):
      return .query(["cursorId": cursorID])
    case .updateFeed(_, _, let model):
      return .body(model)
    case .createComment(_, _, let model):
      return .body(model)
    case .updateComment(_, _, _, let content):
      return .body(["content": content])
    default:
      return .plain
    }
  }
  
  var headers: HeaderType {
    return .withAccessToken
  }
}
