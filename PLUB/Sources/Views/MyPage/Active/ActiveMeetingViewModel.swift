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
  // MARK: Property
  var plumbingID: Int { get }
  var todoList: [TodoContent] { get }
  var feedList: [FeedsContent] { get }
  
  // MARK: Input
  
  // MARK: Output
  var meetingInfoDriver: Driver<RecruitingModel> { get } // 내 정보 데이터
  var reloadTaleViewDriver: Driver<Void> { get } // 테이블 뷰 리로드
}

final class ActiveMeetingViewModel {
  private let disposeBag = DisposeBag()
  
  // MARK: Property
  private(set) var plubbingID: Int
  private(set) var todoList = [TodoContent]()
  private(set) var feedList = [FeedsContent]()
  
  // MARK: UseCase
  private let inquireMyTodoUseCase: InquireMyTodoUseCase
  private let inquireMyFeedUseCase: InquireMyFeedUseCase
  
  // MARK: Subjects
  private let meetingInfoSubject = PublishSubject<RecruitingModel>()
  private let reloadTaleViewSubject = PublishSubject<Void>()
  
  init(
    plubbingID: Int,
    inquireMyTodoUseCase: InquireMyTodoUseCase,
    inquireMyFeedUseCase: InquireMyFeedUseCase
  ) {
    self.plubbingID = plubbingID
    self.inquireMyTodoUseCase = inquireMyTodoUseCase
    self.inquireMyFeedUseCase = inquireMyFeedUseCase
    
    fetchActiveMeetingData()
  }
  
  private func fetchActiveMeetingData(){
    let myTodo = inquireMyTodoUseCase
      .execute(plubbingID: plubbingID, cursorID: 0)
    let myFeed = inquireMyFeedUseCase
      .execute(plubbingID: plubbingID, cursorID: 0)
    
    Observable.zip(myTodo, myFeed)
      .subscribe(with: self) { owner, result in
        let (myTodoResult, myFeedResult) = result
        owner.handleMeetingInfo(plubbing: myTodoResult.plubbingInfo)
        owner.handleMyTodoInfo(todoInfo: myTodoResult.todoInfo)
        owner.handleMyFeedInfo(feedInfo: myFeedResult.feedInfo)
        owner.reloadTaleViewSubject.onNext(())
      }
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
  
  private func handleMyTodoInfo(todoInfo: TodoInfo) {
    todoList = todoInfo.todoContent
      .prefix(2)
      .map { $0 }
  }
  
  private func handleMyFeedInfo(feedInfo: FeedInfo) {
    feedList = feedInfo.feedList
      .filter { $0.viewType != .system }
      .prefix(2)
      .map { $0 }
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
  // MARK: Property
  var plumbingID: Int {
    plubbingID
  }
  
  // MARK: Input
  
  // MARK: Output
  var meetingInfoDriver: Driver<RecruitingModel> { meetingInfoSubject.asDriver(onErrorDriveWith: .empty())
  }
  
  var reloadTaleViewDriver: Driver<Void> { reloadTaleViewSubject.asDriver(onErrorDriveWith: .empty())
  }
}
