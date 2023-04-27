//
//  GetCommentsUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/10.
//

import RxSwift

protocol GetCommentsUseCase {
  func execute(nextCursorID: Int) -> Observable<(content: [CommentContent], nextCursorID: Int, isLast: Bool)>
}

final class DefaultGetCommentsUseCase: GetCommentsUseCase {
  
  private let plubbingID: Int
  private let feedID: Int
  
  init(plubbingID: Int, feedID: Int) {
    self.plubbingID = plubbingID
    self.feedID = feedID
  }
  
  func execute(nextCursorID: Int) -> Observable<(content: [CommentContent], nextCursorID: Int, isLast: Bool)> {
    FeedsService.shared.fetchComments(
      plubbingID: plubbingID,
      feedID: feedID,
      nextCursorID: nextCursorID
    )
    .map { data in
      // Mapping for page manager
      return (
        content: data.content,
        nextCursorID: data.content.last?.commentID ?? 0,
        isLast: data.isLast
      )
    }
  }
}
