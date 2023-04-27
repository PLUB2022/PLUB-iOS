//
//  PostCommentUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/09.
//

import RxSwift

protocol PostCommentUseCase {
  func execute(context: String, commentParentID: Int?) -> Observable<CommentContent>
}

final class DefaultPostCommentUseCase: PostCommentUseCase {
  
  private let plubbingID: Int
  private let feedID: Int
  
  init(plubbingID: Int, feedID: Int) {
    self.plubbingID = plubbingID
    self.feedID = feedID
  }
  
  func execute(context: String, commentParentID: Int?) -> Observable<CommentContent> {
    FeedsService.shared.createComments(
      plubbingID: plubbingID,
      feedID: feedID,
      comment: context,
      commentParentID: commentParentID
    )
  }
}
