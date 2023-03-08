//
//  ScheduleParticipantViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/05.
//

import RxSwift
import RxCocoa
import Then

final class ScheduleParticipantViewModel {
  private let disposeBag = DisposeBag()
  
  private let plubbingID: Int
  private let calendarID: Int
  
  init(
    plubbingID: Int,
    calendarID: Int
  ) {
    self.plubbingID = plubbingID
    self.calendarID = calendarID
  }
  
  func attendSchedule(type: AttendScheduleType) {
    ScheduleService.shared
      .attendSchedule(
        plubbingID: plubbingID,
        calendarID: calendarID,
        request: .init(attendStatus: type.rawValue)
      )
      .subscribe(with: self) { owner, result in
        switch result {
        case .success(let model):
          print(model)
        default: break// TODO: 수빈 - PLUB 에러 Alert 띄우기
        }
      }
      .disposed(by: disposeBag)
  }
}
