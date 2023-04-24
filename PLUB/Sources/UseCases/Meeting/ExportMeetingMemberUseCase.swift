//
//  ExportMeetingMemberUseCase.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/23.
//

import RxSwift

protocol ExportMeetingMemberUseCase {
  func execute(plubbingID: Int, accountID: Int)
  -> Observable<Void>
}

final class DefaultExportMeetingMemberUseCase: ExportMeetingMemberUseCase {
  func execute(plubbingID: Int, accountID: Int)
  -> Observable<Void> {
    MeetingService.shared.exportMeetingMember(plubbingID: plubbingID, accountID: accountID)
      .map { _ in () }
  }
}
