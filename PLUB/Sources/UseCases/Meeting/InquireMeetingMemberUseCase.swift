//
//  InquireMeetingMemberUseCase.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/23.
//

import RxSwift

protocol InquireMeetingMemberUseCase {
  func execute(plubbingID: Int)
  -> Observable<[AccountInfo]>
}

final class DefaultInquireMeetingMemberUseCase: InquireMeetingMemberUseCase {
  func execute(plubbingID: Int)
  -> Observable<[AccountInfo]> {
    MeetingService.shared.inquireMeetingMember(plubbingID: plubbingID)
      .map { $0.accounts }
  }
}
