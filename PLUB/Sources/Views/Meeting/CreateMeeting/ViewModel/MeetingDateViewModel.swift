//
//  MeetingDateViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/19.
//

import RxSwift
import RxCocoa

final class MeetingDateViewModel {
  private lazy var disposeBag = DisposeBag()
  
  let dateList = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일", "요일 무관"].map {
    MeetingDateCollectionViewCellModel(date: $0, isSelected: false)
  }
  var dateCellData: BehaviorRelay<[MeetingDateCollectionViewCellModel]>
  
  var dateInputRelay = BehaviorRelay<[String]>.init(value: .init())

  init() {
    dateCellData = .init(value: dateList)
  }
  
  func updateDateData(data: MeetingDateCollectionViewCellModel) {
    var dates = dateInputRelay.value
    var cellDatas = dateCellData.value
    
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
