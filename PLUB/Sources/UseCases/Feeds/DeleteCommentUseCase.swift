// 
//  DeleteCommentUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/17.
//

import RxSwift

protocol DeleteCommentUseCase {
  func execute(plubbingID: Int, feedID: Int, commentID: Int) -> Observable<BaseService.EmptyModel>
}

final class DefaultDeleteCommentUseCase: DeleteCommentUseCase {
  
  func execute(plubbingID: Int, feedID: Int, commentID: Int) -> Observable<BaseService.EmptyModel> {
    FeedsService.shared.deleteComment(plubbingID: plubbingID, feedID: feedID, commentID: commentID)
  }
}
