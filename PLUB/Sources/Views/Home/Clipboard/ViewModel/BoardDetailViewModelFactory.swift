//
//  BoardDetailViewModelFactory.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/20.
//

import Foundation


protocol BoardDetailViewModelFactory {
  static func make(plubbingID: Int, boardModel: BoardModel) -> BoardDetailViewModel
}

final class BoardDetailViewModelWithFeedsFactory: BoardDetailViewModelFactory {
  
  private init() { }
  
  static func make(plubbingID: Int, boardModel: BoardModel) -> BoardDetailViewModel {
    return BoardDetailViewModel(
      plubbingID: plubbingID,
      content: boardModel,
      getCommentsUseCase: DefaultGetCommentsUseCase(),
      postCommentUseCase: DefaultPostCommentUseCase(),
      deleteCommentUseCase: DefaultDeleteCommentUseCase(),
      editCommentUseCase: DefaultEditCommentUseCase()
    )
  }
}
