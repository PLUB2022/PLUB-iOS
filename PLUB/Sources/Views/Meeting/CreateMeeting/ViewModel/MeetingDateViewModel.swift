//
//  MeetingDateViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/19.
//

import RxSwift
import RxCocoa

enum Day: String, CaseIterable {
  case monday = "월"
  case tuesday = "화"
  case wednesday = "수"
  case thursday = "목"
  case friday = "금"
  case saturday = "토"
  case sunday = "일"
  case all = "요일 무관"
}

final class MeetingDateViewModel {
  private let disposeBag = DisposeBag()

  // CellData
  let dateCellData: BehaviorRelay<[MeetingDateCollectionViewCellModel]>
  
  // Input
  let dateInputRelay = BehaviorRelay<[String]>.init(value: .init())
  let timeInputRelay = BehaviorRelay<String>.init(value: .init())
  let onOffInputRelay = BehaviorRelay<String>.init(value: "ON")
  let locationInputRelay = BehaviorRelay<String>.init(value: .init())
  
  // OutPut
  let isBtnEnabled: Observable<Bool>
  
  init() {
    let dateList = Day.allCases
      .map { $0.rawValue }
      .map {
        MeetingDateCollectionViewCellModel(
          date: $0,
          isSelected: false
        )
      }
    dateCellData = .init(value: dateList)
    
    let whereInput = Observable.combineLatest(
      onOffInputRelay,
      locationInputRelay
    ).map {
      if $0.0.contains("ON") {
        return true
      } else if $0.0.contains("OFF") && !$0.1.isEmpty {
        return true
      } else {
        return false
      }
    }
    
    isBtnEnabled = Observable.combineLatest(
      dateInputRelay,
      timeInputRelay,
      whereInput
    ).map {
      return !$0.0.isEmpty &&
      !$0.1.isEmpty &&
      $0.2
    }
  }
  
  func updateDate(data: MeetingDateCollectionViewCellModel) {
    let dates = dateInputRelay.value
    let cellDatas = dateCellData.value
    
    if data.isSelected { // CASE 1) 선택 해제
      dateInputRelay.accept(dates.filter { $0 != data.date })
      dateCellData.accept(
        cellDatas.map {
          MeetingDateCollectionViewCellModel(
            date: $0.date,
            isSelected: $0.date == data.date ? false : $0.isSelected
          )
        }
      )
    }
    else if data.date == "요일 무관" { // CASE 2-1) 요일 무관 선택
      dateInputRelay.accept([data.date])
      dateCellData.accept(
        cellDatas.map {
          MeetingDateCollectionViewCellModel(
            date: $0.date,
            isSelected: $0.date == "요일 무관" ? true : false
          )
        }
      )
    }
    else { // CASE 2-2) 요일 무관 제외한 요일 선택
      var filterDates = dates.filter { $0 != "요일 무관" }
      filterDates.append(data.date)
      dateInputRelay.accept(filterDates)
      
      dateCellData.accept(
        cellDatas.map {
          return MeetingDateCollectionViewCellModel(
            date: $0.date,
            isSelected: {
              if $0.date == "요일 무관" {
                return false
              } else if $0.date == data.date {
                return true
              } else {
                return $0.isSelected
              }
            }($0)
          )
        }
      )
    }
  }
}
