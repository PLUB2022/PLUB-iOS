//
//  PostCommentUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/09.
//

import RxSwift

protocol PostCommentUseCase {
  func execute(plubbingID: Int, feedID: Int, context: String, commentParentID: Int?) -> Observable<CommentContent>
}

final class DefaultPostCommentUseCase: PostCommentUseCase {
  func execute(
    plubbingID: Int,
    feedID: Int,
    context: String,
    commentParentID: Int?
  ) -> Observable<CommentContent> {
    FeedsService.shared.createComments(
      plubbingID: plubbingID,
      feedID: feedID,
      comment: context,
      commentParentID: commentParentID
    )
  }
}
