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
  
  // Output
  let successResult: Driver<Void>
  
  private let successResultSubject = PublishSubject<Void>()
  
  init(
    plubbingID: Int,
    calendarID: Int
  ) {
    self.plubbingID = plubbingID
    self.calendarID = calendarID
    
    successResult = successResultSubject.asDriver(onErrorDriveWith: .empty())
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
          owner.successResultSubject.onNext(())
        default: break// TODO: 수빈 - PLUB 에러 Alert 띄우기
        }
      }
      .disposed(by: disposeBag)
  }
}
