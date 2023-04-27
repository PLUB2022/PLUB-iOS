// 
//  EditCommentUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/19.
//

import RxSwift

protocol EditCommentUseCase {
  func execute(commentID: Int, content: String) -> Observable<CommentContent>
}

final class DefaultEditCommentUseCase: EditCommentUseCase {
  
  
  private let plubbingID: Int
  private let feedID: Int
  
  init(plubbingID: Int, feedID: Int) {
    self.plubbingID = plubbingID
    self.feedID = feedID
  }
  
  func execute(commentID: Int, content: String) -> Observable<CommentContent> {
    FeedsService.shared.updateComment(plubbingID: plubbingID, feedID: feedID, commentID: commentID, comment: content)
  }
}
