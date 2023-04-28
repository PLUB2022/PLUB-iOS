//
//  ActiveMeetingViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/27.
//

import Foundation

import RxSwift
import RxCocoa

class ActiveMeetingViewModel {
  private let disposeBag = DisposeBag()
  private(set) var plubbingID: Int
  
  // Output
  let meetingInfo: Driver<RecruitingModel> // 내 정보 데이터
  
  private let meetingInfoSubject = PublishSubject<RecruitingModel>()
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
    meetingInfo = meetingInfoSubject.asDriver(onErrorDriveWith: .empty())
    
    fetchMyTodo()
  }
  
  private func fetchMyTodo() {
    MyPageService.shared
      .inquireMyTodo(plubbingID: plubbingID, cursorID: 0)
      .withUnretained(self)
      .subscribe (onNext: { owner, response in
        let plubbing = response.plubbingInfo
        owner.meetingInfoSubject.onNext(
          RecruitingModel(
            title: plubbing.name,
            schedule: owner.createScheduleString(
              days: plubbing.days,
              time: plubbing.time
            ),
            address: plubbing.address ?? "")
        )
      })
      .disposed(by: disposeBag)
  }
  
  private func createScheduleString(days: [Day], time: String) -> String {
    let dateStr = days
      .map { $0.kor }
      .joined(separator: ", ")
    
    let date = DateFormatter().then {
      $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
      $0.locale = Locale(identifier: "ko_KR")
    }.date(from: time) ?? Date()

    let timeStr = DateFormatter().then {
      $0.dateFormat = "a h시 m분"
      $0.locale = Locale(identifier: "ko_KR")
    }.string(from: date)
    
    return (dateStr.isEmpty ? "온라인" : dateStr)  + " | " + timeStr
  }
}
