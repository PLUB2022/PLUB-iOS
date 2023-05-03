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
  
  private let inquireMyTodoUseCase: InquireMyTodoUseCase
  
  // Output
  let meetingInfo: Driver<RecruitingModel> // 내 정보 데이터
  
  private let meetingInfoSubject = PublishSubject<RecruitingModel>()
  
  init(plubbingID: Int, inquireMyTodoUseCase: InquireMyTodoUseCase) {
    self.plubbingID = plubbingID
    self.inquireMyTodoUseCase = inquireMyTodoUseCase
    
    meetingInfo = meetingInfoSubject.asDriver(onErrorDriveWith: .empty())
    
    fetchMyTodo()
  }
  
  private func fetchMyTodo() {
    inquireMyTodoUseCase
      .execute(plubbingID: plubbingID, cursorID: 0)
      .withUnretained(self)
      .subscribe(onNext: { owner, model in
        owner.handleMeetingInfo(plubbing: model.plubbingInfo)
      })
      .disposed(by: disposeBag)
  }
  
  private func handleMeetingInfo(plubbing: PlubbingInfo) {
    meetingInfoSubject.onNext(
      RecruitingModel(
        title: plubbing.name,
        schedule: createScheduleString(
          days: plubbing.days,
          time: plubbing.time
        ),
        address: plubbing.address ?? "")
    )
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
