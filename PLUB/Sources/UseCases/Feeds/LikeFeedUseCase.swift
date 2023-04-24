// 
//  LikeFeedUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/24.
//

import RxSwift

protocol LikeFeedUseCase {
  func execute(plubbingID: Int, feedID: Int) -> Observable<Void>
}

final class DefaultLikeFeedUseCase: LikeFeedUseCase {
  
  func execute(plubbingID: Int, feedID: Int) -> Observable<Void> {
    FeedsService.shared.likeFeed(plubbingID: plubbingID, feedID: feedID).map { _ in Void() }
  }
}
