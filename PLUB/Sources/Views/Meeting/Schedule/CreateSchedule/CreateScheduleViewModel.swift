//
//  CreateScheduleViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/18.
//

import Foundation

import RxSwift
import RxCocoa

final class CreateScheduleViewModel {
  private let disposeBag = DisposeBag()
  
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
  
  private let scheduleRelay = BehaviorRelay<CreateScheduleRequest>(value: CreateScheduleRequest())
  
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
    
    bind()
  }
  
  private func bind() {
    titleSubject
      .withUnretained(self)
      .map { owner, title in
        owner.scheduleRelay.value.with {
          $0.title = title
        }
      }
      .bind(to: scheduleRelay)
      .disposed(by: disposeBag)
    
    allDaySwitchSubject
      .withUnretained(self)
      .map { owner, isAllDay in
        owner.scheduleRelay.value.with {
          $0.isAllDay = isAllDay
        }
      }
      .bind(to: scheduleRelay)
      .disposed(by: disposeBag)
    
    startDateSubject
      .withUnretained(self)
      .map { owner, date in
        owner.scheduleRelay.value.with {
          $0.startDay = owner.setupDay(date)
          $0.startTime = owner.setupTime(date)
        }
      }
      .bind(to: scheduleRelay)
      .disposed(by: disposeBag)
    
    endDateSubject
      .withUnretained(self)
      .map { owner, date in
        owner.scheduleRelay.value.with {
          $0.endDay = owner.setupDay(date)
          $0.endTime = owner.setupTime(date)
        }
      }
      .bind(to: scheduleRelay)
      .disposed(by: disposeBag)
    
    locationSubject
      .withUnretained(self)
      .map { owner, location in
        owner.scheduleRelay.value.with {
          $0.address = location.address ?? ""
          $0.roadAddress = location.roadAddress ?? ""
          $0.placeName = location.placeName ?? ""
        }
      }
      .bind(to: scheduleRelay)
      .disposed(by: disposeBag)
    
    alarmSubject
      .withUnretained(self)
      .map { owner, alarm in
        owner.scheduleRelay.value
          //TODO: 수빈 alarm 데이터 추가(alarm.value)
      }
      .bind(to: scheduleRelay)
      .disposed(by: disposeBag)
    
    memoSubject
      .withUnretained(self)
      .map { owner, memo in
        owner.scheduleRelay.value.with {
          $0.memo = memo
        }
      }
      .bind(to: scheduleRelay)
      .disposed(by: disposeBag)
  }
  
  private func setupDay(_ date: Date) -> String {
    return DateFormatter().then {
      $0.dateFormat = "yyyy-MM-dd"
    }.string(from: date)
  }
  
  private func setupTime(_ date: Date) -> String {
    return DateFormatter().then {
      $0.dateFormat = "hh:mm"
    }.string(from: date)
  }
  
  func createSchedule() {
    ScheduleService.shared
      .createSchedule(
        plubbingID: "21",
        request: scheduleRelay.value
      )
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          print(model)
        default: break// TODO: 수빈 - PLUB 에러 Alert 띄우기
        }
      })
      .disposed(by: disposeBag)
  }
}
