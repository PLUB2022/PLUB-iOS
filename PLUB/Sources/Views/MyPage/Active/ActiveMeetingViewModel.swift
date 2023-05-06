//
//  ActiveMeetingViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/27.
//

import Foundation

import RxSwift
import RxCocoa

protocol ActiveMeetingViewModelType {
  // MARK: Input
  
  // MARK: Output
  var meetingInfoDriver: Driver<RecruitingModel> { get } // 내 정보 데이터
}

final class ActiveMeetingViewModel {
  private let disposeBag = DisposeBag()
  private(set) var plubbingID: Int
  
  private let inquireMyTodoUseCase: InquireMyTodoUseCase
  
  // MARK: Subjects
  
  private let meetingInfoSubject = PublishSubject<RecruitingModel>()
  
  init(plubbingID: Int, inquireMyTodoUseCase: InquireMyTodoUseCase) {
    self.plubbingID = plubbingID
    self.inquireMyTodoUseCase = inquireMyTodoUseCase
    
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
    
    let date = DateFormatterFactory.dateTime
      .date(from: time) ?? Date()

    let timeStr = DateFormatterFactory.koreanTime
      .string(from: date)
    
    return (dateStr.isEmpty ? "온라인" : dateStr)  + " | " + timeStr
  }
}


extension ActiveMeetingViewModel: ActiveMeetingViewModelType {
  // MARK: Input
  
  // MARK: Output
  var meetingInfoDriver: Driver<RecruitingModel> { meetingInfoSubject.asDriver(onErrorDriveWith: .empty())
  }
}
