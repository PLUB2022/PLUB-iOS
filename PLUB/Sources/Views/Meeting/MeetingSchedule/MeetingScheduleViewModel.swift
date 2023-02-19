//
//  MeetingScheduleViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/18.
//

import Foundation

import RxSwift
import RxCocoa

final class MeetingScheduleViewModel {
  let scheduleType = MeetingScheduleType.allCases
  
  // Input
  let title: AnyObserver<String>
  let allDay: AnyObserver<Bool>
  let startDate: AnyObserver<Date>
  let endDate: AnyObserver<Date>
  let location: AnyObserver<Location>
  let alarm: AnyObserver<ScheduleAlarmType>
  let memo: AnyObserver<String>
  
  // Output
  let isButtonEnabled: Driver<Bool>

  private let titleSubject = PublishSubject<String>()
  private let allDaySwitchSubject = PublishSubject<Bool>()
  private let startDateSubject = PublishSubject<Date>()
  private let endDateSubject = PublishSubject<Date>()
  private let locationSubject = PublishSubject<Location>()
  private let alarmSubject = PublishSubject<ScheduleAlarmType>()
  private let memoSubject = PublishSubject<String>()
  
//  private let scheduleRelay = BehaviorRelay<CreateScheduleRequest>(value: init())
  
  init() {
    title = titleSubject.asObserver()
    allDay = allDaySwitchSubject.asObserver()
    startDate = startDateSubject.asObserver()
    endDate = endDateSubject.asObserver()
    location = locationSubject.asObserver()
    alarm = alarmSubject.asObserver()
    memo = memoSubject.asObserver()
    
    isButtonEnabled = Driver.combineLatest(
      titleSubject.asDriver(onErrorDriveWith: .empty()),
      memoSubject.asDriver(onErrorDriveWith: .empty())
    ){
      !$0.isEmpty &&
      !$1.isEmpty &&
      $1 != "메모 내용을 입력해주세요."
    }
  }
  
  private func bind() {
    titleSubject
      .withUnretained(self)
  }
}
