// 
//  DeleteFeedUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/05/13.
//

import RxSwift

protocol DeleteFeedUseCase {
  func execute() -> Observable<Void>
}

final class DefaultDeleteFeedUseCase: DeleteFeedUseCase {
  
  private let plubbingID: Int
  private let feedID: Int
  
  init(plubbingID: Int, feedID: Int) {
    self.plubbingID = plubbingID
    self.feedID = feedID
  }
  
  
  func execute() -> Observable<Void> {
    FeedsService.shared.deleteFeed(plubbingID: plubbingID, feedID: feedID)
      .map { _ in Void() }
  }
}
