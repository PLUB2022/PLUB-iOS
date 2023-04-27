// 
//  GetFeedDetailUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/25.
//

import RxSwift

protocol GetFeedDetailUseCase {
  func execute() -> Observable<FeedsContent>
}

final class DefaultGetFeedDetailUseCase: GetFeedDetailUseCase {
  
  private let plubbingID: Int
  private let feedID: Int
  
  init(plubbingID: Int, feedID: Int) {
    self.plubbingID = plubbingID
    self.feedID = feedID
  }
  
  func execute() -> Observable<FeedsContent> {
    FeedsService.shared.fetchFeedDetails(plubbingID: plubbingID, feedID: feedID)
  }
}
