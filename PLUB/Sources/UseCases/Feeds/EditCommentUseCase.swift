// 
//  EditCommentUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/19.
//

import RxSwift

protocol EditCommentUseCase {
  func execute(plubbingID: Int, feedID: Int, commentID: Int, content: String) -> Observable<CommentContent>
}

final class DefaultEditCommentUseCase: EditCommentUseCase {
  
  func execute(plubbingID: Int, feedID: Int, commentID: Int, content: String) -> Observable<CommentContent> {
    FeedsService.shared.updateComment(plubbingID: plubbingID, feedID: feedID, commentID: commentID, comment: content)
  }
}
