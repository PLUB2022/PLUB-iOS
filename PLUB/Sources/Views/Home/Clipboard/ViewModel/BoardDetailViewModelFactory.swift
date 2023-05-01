//
//  BoardDetailViewModelFactory.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/20.
//

import Foundation


protocol BoardDetailViewModelFactory {
  static func make(plubbingID: Int, feedID: Int) -> BoardDetailViewModelType
}

final class BoardDetailViewModelWithFeedsFactory: BoardDetailViewModelFactory {
  
  private init() { }
  
  static func make(plubbingID: Int, feedID: Int) -> BoardDetailViewModelType {
    return BoardDetailViewModel(
      getFeedDetailUseCase: DefaultGetFeedDetailUseCase(plubbingID: plubbingID, feedID: feedID),
      getCommentsUseCase: DefaultGetCommentsUseCase(plubbingID: plubbingID, feedID: feedID),
      postCommentUseCase: DefaultPostCommentUseCase(plubbingID: plubbingID, feedID: feedID),
      deleteCommentUseCase: DefaultDeleteCommentUseCase(plubbingID: plubbingID, feedID: feedID),
      editCommentUseCase: DefaultEditCommentUseCase(plubbingID: plubbingID, feedID: feedID),
      likeFeedUseCase: DefaultLikeFeedUseCase(plubbingID: plubbingID, feedID: feedID)
    )
  }
}
