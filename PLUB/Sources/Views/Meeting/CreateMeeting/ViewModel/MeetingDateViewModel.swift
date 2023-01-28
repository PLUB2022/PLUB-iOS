//
//  MeetingDateViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/19.
//

import RxSwift
import RxCocoa

enum Day: CaseIterable {
  case MON
  case TUE
  case WED
  case THR
  case FRI
  case SAT
  case SUN
  case ALL
  
  var toKOR: String {
    switch self {
    case .MON:
      return "월"
    case .TUE:
      return "화"
    case .WED:
      return "수"
    case .THR:
      return "목"
    case .FRI:
      return "금"
    case .SAT:
      return "토"
    case .SUN:
      return "일"
    case .ALL:
      return "요일 무관"
    }
  }
}

final class MeetingDateViewModel {
  private lazy var disposeBag = DisposeBag()

  // CellData
  var dateCellData: BehaviorRelay<[MeetingDateCollectionViewCellModel]>
  
  // Input
  var dateInputRelay = BehaviorRelay<[String]>.init(value: .init())
  var timeInputRelay = BehaviorRelay<String>.init(value: .init())
  var onOffInputRelay = BehaviorRelay<String>.init(value: .init())
  var locationInputRelay = BehaviorRelay<String>.init(value: .init())
  
  // OutPut
  var isBtnEnabled: Observable<Bool>
  
  init() {
    let dateList = Day.allCases
      .map { $0.toKOR }
      .map {
        MeetingDateCollectionViewCellModel(
          date: $0,
          isSelected: false
        )
      }
    dateCellData = .init(value: dateList)
    
    isBtnEnabled = Observable.combineLatest(
      dateInputRelay,
      timeInputRelay,
      onOffInputRelay,
      locationInputRelay
    ).map {
      return !$0.0.isEmpty &&
      !$0.1.isEmpty &&
      !$0.2.isEmpty &&
      !$0.3.isEmpty
    }
  }
  
  func updateDateData(data: MeetingDateCollectionViewCellModel) {
    let dates = dateInputRelay.value
    let cellDatas = dateCellData.value
    
    if data.isSelected { // CASE 1) 선택 해제
      dateInputRelay.accept(dates.filter { $0 != data.date.fromENGToKOR() })
      dateCellData.accept(
        cellDatas.map {
          MeetingDateCollectionViewCellModel(
            date: $0.date,
            isSelected: $0.date == data.date ? false : $0.isSelected
          )
        }
      )
    } else { // CASE 2) 선택
      if data.date == "요일 무관" { // CASE 2-1) 요일 무관
        dateInputRelay.accept([data.date.fromENGToKOR()])
        dateCellData.accept(
          cellDatas.map {
            MeetingDateCollectionViewCellModel(
              date: $0.date,
              isSelected: $0.date == "요일 무관" ? true : false
            )
          }
        )
      } else { // CASE 2-1) 요일 무관 제외한 요일
        var filterDates = dates.filter { $0 != "ALL" }
        filterDates.append(data.date.fromENGToKOR())
        dateInputRelay.accept(filterDates)
        
        dateCellData.accept(
          cellDatas.map {
            var isSelected = false
            if $0.date == "요일 무관" {
              isSelected = false
            } else if $0.date == data.date {
              isSelected = true
            } else {
              isSelected = $0.isSelected
            }
            
            return MeetingDateCollectionViewCellModel(
              date: $0.date,
              isSelected: isSelected
            )
          }
        )
      }
    }
  }
}
