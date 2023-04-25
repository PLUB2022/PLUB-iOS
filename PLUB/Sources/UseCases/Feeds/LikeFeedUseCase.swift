// 
//  LikeFeedUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/24.
//

import RxSwift

protocol LikeFeedUseCase {
  func execute() -> Observable<Void>
}

final class DefaultLikeFeedUseCase: LikeFeedUseCase {
  
  private let plubbingID: Int
  private let feedID: Int
  
  init(plubbingID: Int, feedID: Int) {
    self.plubbingID = plubbingID
    self.feedID = feedID
  }
  
  func execute() -> Observable<Void> {
    FeedsService.shared.likeFeed(plubbingID: plubbingID, feedID: feedID).map { _ in Void() }
  }
}
