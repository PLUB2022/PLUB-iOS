//
//  InquireMyFeedUseCase.swift
//  PLUB
//
//  Created by 김수빈 on 2023/05/06.
//

import UIKit

import RxSwift

protocol InquireMyFeedUseCase {
  func execute(plubbingID: Int, cursorID: Int) -> Observable<MyFeedResponse>
}

final class DefaultInquireMyFeedUseCase: InquireMyFeedUseCase {
  
  func execute(plubbingID: Int, cursorID: Int) -> Observable<MyFeedResponse> {
    MyPageService.shared
      .inquireMyFeed(plubbingID: plubbingID, cursorID: cursorID)
  }
}
