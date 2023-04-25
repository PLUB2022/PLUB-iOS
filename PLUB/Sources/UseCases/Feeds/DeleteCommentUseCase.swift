// 
//  DeleteCommentUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/17.
//

import RxSwift

protocol DeleteCommentUseCase {
  func execute(commentID: Int) -> Observable<BaseService.EmptyModel>
}

final class DefaultDeleteCommentUseCase: DeleteCommentUseCase {
  
  private let plubbingID: Int
  private let feedID: Int
  
  init(plubbingID: Int, feedID: Int) {
    self.plubbingID = plubbingID
    self.feedID = feedID
  }
  
  func execute(commentID: Int) -> Observable<BaseService.EmptyModel> {
    FeedsService.shared.deleteComment(plubbingID: plubbingID, feedID: feedID, commentID: commentID)
  }
}
