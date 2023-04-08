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
  ///   - plubbingID: 플럽 모임 ID
  ///   - model: 게시판 요청 모델
  func createBoards(plubbingID: Int, model: BoardsRequest) -> Observable<BoardsResponse> {
    sendObservableRequest(FeedsRouter.createBoard(plubbingID: plubbingID, model: model))
  }
  
  /// 게시판을 조회합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - nextCursorID: 다음에 요청할 커서 위치, 기본값은 0입니다.
  func fetchBoards(plubbingID: Int, nextCursorID: Int = 0) -> Observable<PaginatedDataResponse<FeedsContent>> {
    sendObservableRequest(FeedsRouter.fetchBoards(plubbingID: plubbingID, cursorID: nextCursorID))
  }
  
  /// 클립보드를 조회합니다.
  /// - Parameter plubbingID: 플럽 모임 ID
  func fetchClipboards(plubbingID: Int) -> Observable<FeedsClipboardResponse> {
    sendObservableRequest(FeedsRouter.fetchClipboards(plubbingID: plubbingID))
  }
  
  /// 게시글 상세 조회할 때 사용됩니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - feedID: 피드(게시글) ID
  func fetchFeedDetails(plubbingID: Int, feedID: Int) -> Observable<FeedsContent> {
    sendObservableRequest(FeedsRouter.fetchFeedDetails(plubbingID: plubbingID, feedID: feedID))
  }
  
  /// 피드(게시글)을 수정합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - feedID: 피드(게시글) ID
  ///   - model: 게시글 요청 모델(`BoardsRequest`)
  func updateFeed(plubbingID: Int, feedID: Int, model: BoardsRequest) -> Observable<BoardsResponse> {
    sendObservableRequest(FeedsRouter.updateFeed(plubbingID: plubbingID, feedID: feedID, model: model))
  }
  
  /// 피드(게시글)을 삭제합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - feedID: 피드(게시글) ID
  func deleteFeed(plubbingID: Int, feedID: Int) -> Observable<EmptyModel> {
    sendObservableRequest(FeedsRouter.deleteFeed(plubbingID: plubbingID, feedID: feedID))
  }
  
  /// 피드(게시글)을 클립보드에 고정합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - feedID: 피드(게시글) ID
  func pinFeed(plubbingID: Int, feedID: Int) -> Observable<BoardsResponse> {
    sendObservableRequest(FeedsRouter.pinFeed(plubbingID: plubbingID, feedID: feedID))
  }
  
  /// 피드(게시글)에 좋아요를 누를 때 사용됩니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - feedID: 피드(게시글) ID
  func likeFeed(plubbingID: Int, feedID: Int) -> Observable<EmptyModel> {
    sendObservableRequest(FeedsRouter.likeFeed(plubbingID: plubbingID, feedID: feedID))
  }
  
  /// 피드(게시글)의 댓글을 조회합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - feedID: 피드(게시글) ID
  ///   - nextCursorID: 다음에 요청할 커서 위치, 기본값은 0입니다.
  func fetchComments(plubbingID: Int, feedID: Int, nextCursorID: Int = 0) -> Observable<PaginatedDataResponse<CommentContent>> {
    sendObservableRequest(FeedsRouter.fetchComments(plubbingID: plubbingID, feedID: feedID, cursorID: nextCursorID))
  }
  
  /// 피드(게시글)에 댓글을 생성합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - feedID: 피드(게시글) ID
  ///   - comment: 댓글 내용
  ///   - commentParentID: 대댓글인 경우, 해당 부모 댓글 ID를 요청으로 보내야합니다.
  ///   만약 일반 댓글인 경우 해당 값은 nil로 처리하면 됩니다. 기본값은 `nil`입니다.
  func createComments(plubbingID: Int, feedID: Int, comment: String, commentParentID: Int? = nil) -> Observable<CommentContent> {
    sendObservableRequest(
      FeedsRouter.createComment(
        plubbingID: plubbingID,
        feedID: feedID,
        model: CommentsRequest(content: comment, parentCommentID: commentParentID)
      )
    )
  }
  
  /// 댓글을 수정합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - feedID: 피드(게시글) ID
  ///   - commentID: 댓글 ID
  ///   - comment: 수정할 댓글 내용
  func updateComment(plubbingID: Int, feedID: Int, commentID: Int, comment: String) -> PLUBResult<CommentContent> {
    sendRequest(
      FeedsRouter.updateComment(plubbingID: plubbingID, feedID: feedID, commentID: commentID, content: comment),
      type: CommentContent.self
    )
  }
  
  /// 댓글을 삭제합니다. 만약 부모 댓글이 삭제되는 경우, 자식 댓글도 전부 삭제됩니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - feedID: 피드(게시글) ID
  ///   - commentID: 댓글 ID
  func deleteComment(plubbingID: Int, feedID: Int, commentID: Int) -> PLUBResult<EmptyModel> {
    sendRequest(FeedsRouter.deleteComment(plubbingID: plubbingID, feedID: feedID, commentID: commentID))
  }
}
