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
      .map { $0.toKOR }
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
    let dates = dateInputRelay.value // 선택된 요일 ENG 값 배열 (ex: [MON, TUE...])
    let cellDatas = dateCellData.value // collectionView 셀 데이터 (date: 요일, isSelected: 선택 여부)
    
    if data.isSelected { // CASE 1) 선택 해제
      dateInputRelay.accept(dates.filter { $0 != data.date.fromENGToKOR() }) // 선택된 요일 값 삭제
      dateCellData.accept(
        cellDatas.map {
          MeetingDateCollectionViewCellModel(
            date: $0.date,
            isSelected: $0.date == data.date ? false : $0.isSelected // 선택된 요일 값만 isSelected false로 변경
          )
        }
      )
    }
    else if data.date == "요일 무관" { // CASE 2) 요일 무관 선택
      dateInputRelay.accept([data.date.fromENGToKOR()]) // "요일 무관"만 존재
      dateCellData.accept(
        cellDatas.map {
          MeetingDateCollectionViewCellModel(
            date: $0.date,
            isSelected: $0.date == "요일 무관" ? true : false // "요일 무관"만 isSelected true, 나머지는 false로 변경
          )
        }
      )
    }
    else { // CASE 3) 요일 무관 제외한 요일 선택
      var filterDates = dates.filter { $0 != "요일 무관" } // "요일 무관" 삭제하고,
      filterDates.append(data.date.fromENGToKOR()) // 선택된 요일 값 추가
      dateInputRelay.accept(filterDates)
      
      dateCellData.accept(
        cellDatas.map {
          return MeetingDateCollectionViewCellModel(
            date: $0.date,
            isSelected: {
              if $0.date == "요일 무관" { // "요일 무관"은 isSelected false
                return false
              } else if $0.date == data.date { // 선택된 요일은 isSelected true
                return true
              } else { // 나머지 요일은 이전 값 유지
                return $0.isSelected
              }
            }($0)
          )
        }
      )
    }
  }
}
