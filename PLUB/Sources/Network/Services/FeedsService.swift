// 
//  FeedsService.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Foundation

import RxSwift
import RxCocoa

final class FeedsService: BaseService {
  static let shared = FeedsService()
  
  private override init() { }
}

extension FeedsService {
  
  /// 게시판을 생성합니다.
  /// - Parameters:
  ///   - plubIdentifier: 플럽 모임 ID
  ///   - model: 게시판 요청 모델
  func createBoards(plubIdentifier: Int, model: BoardsRequest) -> PLUBResult<BoardsResponse> {
    sendRequest(
      FeedsRouter.createBoard(plubID: plubIdentifier, model: model),
      type: BoardsResponse.self
    )
  }
  
  /// 게시판을 조회합니다.
  /// - Parameters:
  ///   - plubIdentifier: 플럽 모임 ID
  ///   - page: 페이지 위치, 기본값은 1입니다.
  func fetchBoards(plubIdentifier: Int, page: Int = 1) -> PLUBResult<FeedsPaginatedDataResponse<FeedsContent>> {
    sendRequest(
      FeedsRouter.fetchBoards(plubID: plubIdentifier, page: page),
      type: FeedsPaginatedDataResponse<FeedsContent>.self
    )
  }
  
  /// 클립보드를 조회합니다.
  /// - Parameter plubIdentifier: 플럽 모임 ID
  func fetchClipboards(plubIdentifier: Int) -> PLUBResult<FeedsClipboardResponse> {
    sendRequest(
      FeedsRouter.fetchClipboards(plubID: plubIdentifier),
      type: FeedsClipboardResponse.self
    )
  }
  
  /// 게시글 상세 조회할 때 사용됩니다.
  /// - Parameters:
  ///   - plubIdentifier: 플럽 모임 ID
  ///   - feedIdentifier: 피드(게시글) ID
  func fetchFeedDetails(plubIdentifier: Int, feedIdentifier: Int) -> PLUBResult<FeedsContent> {
    sendRequest(
      FeedsRouter.fetchFeedDetails(plubID: plubIdentifier, feedID: feedIdentifier),
      type: FeedsContent.self
    )
  }
  
  /// 피드(게시글)을 수정합니다.
  /// - Parameters:
  ///   - plubIdentifier: 플럽 모임 ID
  ///   - feedIdentifier: 피드(게시글) ID
  ///   - model: 게시글 요청 모델(`BoardsRequest`)
  func updateFeed(plubIdentifier: Int, feedIdentifier: Int, model: BoardsRequest) -> PLUBResult<BoardsResponse> {
    sendRequest(
      FeedsRouter.updateFeed(plubID: plubIdentifier, feedID: feedIdentifier, model: model),
      type: BoardsResponse.self
    )
  }
  
  /// 피드(게시글)을 삭제합니다.
  /// - Parameters:
  ///   - plubIdentifier: 플럽 모임 ID
  ///   - feedIdentifier: 피드(게시글) ID
  func deleteFeed(plubIdentifier: Int, feedIdentifier: Int) -> PLUBResult<EmptyModel> {
    sendRequest(FeedsRouter.deleteFeed(plubID: plubIdentifier, feedID: feedIdentifier))
  }
  
  /// 피드(게시글)을 클립보드에 고정합니다.
  /// - Parameters:
  ///   - plubIdentifier: 플럽 모임 ID
  ///   - feedIdentifier: 피드(게시글) ID
  func pinFeed(plubIdentifier: Int, feedIdentifier: Int) -> PLUBResult<BoardsResponse> {
    sendRequest(
      FeedsRouter.pinFeed(plubID: plubIdentifier, feedID: feedIdentifier),
      type: BoardsResponse.self
    )
  }
  
  /// 피드(게시글)에 좋아요를 누를 때 사용됩니다.
  /// - Parameters:
  ///   - plubIdentifier: 플럽 모임 ID
  ///   - feedIdentifier: 피드(게시글) ID
  func likeFeed(plubIdentifier: Int, feedIdentifier: Int) -> PLUBResult<EmptyModel> {
    sendRequest(FeedsRouter.likeFeed(plubID: plubIdentifier, feedID: feedIdentifier))
  }
  
  /// 피드(게시글)의 댓글을 조회합니다.
  /// - Parameters:
  ///   - plubIdentifier: 플럽 모임 ID
  ///   - feedIdentifier: 피드(게시글) ID
  ///   - page: 페이지 위치, 기본값은 1입니다.
  func fetchComments(plubIdentifier: Int, feedIdentifier: Int, page: Int = 1) -> PLUBResult<FeedsPaginatedDataResponse<CommentContent>> {
    sendRequest(
      FeedsRouter.fetchComments(plubID: plubIdentifier, feedID: feedIdentifier, page: page),
      type: FeedsPaginatedDataResponse<CommentContent>.self
    )
  }
  
  /// 피드(게시글)에 댓글을 생성합니다.
  /// - Parameters:
  ///   - plubIdentifier: 플럽 모임 ID
  ///   - feedIdentifier: 피드(게시글) ID
  ///   - comment: 댓글 내용
  ///   - commentParentIdentifier: 대댓글인 경우, 해당 부모 댓글 ID를 요청으로 보내야합니다.
  ///   만약 일반 댓글인 경우 해당 값은 nil로 처리하면 됩니다. 기본값은 `nil`입니다.
  func createComments(plubIdentifier: Int, feedIdentifier: Int, comment: String, commentParentIdentifier: Int? = nil) -> PLUBResult<EmptyModel> {
    sendRequest(
      FeedsRouter.createComment(
        plubID: plubIdentifier,
        feedID: feedIdentifier,
        model: CommentsRequest(content: comment, parentCommentID: commentParentIdentifier))
    )
  }
  
  /// 댓글을 수정합니다.
  /// - Parameters:
  ///   - plubIdentifier: 플럽 모임 ID
  ///   - feedIdentifier: 피드(게시글) ID
  ///   - commentIdentifier: 댓글 ID
  ///   - comment: 수정할 댓글 내용
  func updateComment(plubIdentifier: Int, feedIdentifier: Int, commentIdentifier: Int, comment: String) -> PLUBResult<CommentContent> {
    sendRequest(
      FeedsRouter.updateComment(plubID: plubIdentifier, feedID: feedIdentifier, commentID: commentIdentifier, content: comment),
      type: CommentContent.self
    )
  }
}
