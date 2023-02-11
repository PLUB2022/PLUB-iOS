//
//  MeetingInfoViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/11.
//

import UIKit

import RxSwift
import RxCocoa

final class MeetingInfoViewModel {
  
  private lazy var disposeBag = DisposeBag()
  
  // CellData
  let dateCellData: BehaviorRelay<[MeetingDateCollectionViewCellModel]>
  // Input
  let dateInputRelay = BehaviorRelay<[String]>.init(value: .init())
  let onOffInputRelay = BehaviorRelay<OnOff>.init(value: .on)
  let locationInputRelay = BehaviorRelay<Location?>.init(value: nil)
  let peopleNumber = BehaviorRelay<Int>.init(value: .init())
  
  // Output
  let fetchedMeetingData = PublishSubject<EditMeetingRequest>()
  
  
  
  private var request = EditMeetingRequest()
  
  init(plubbingID: String) {
    let dateList = Day.allCases
      .map { $0.kor }
      .map {
        MeetingDateCollectionViewCellModel(
          date: $0,
          isSelected: false
        )
      }
    dateCellData = .init(value: dateList)
    
    fetchMeetingData(plubbingID: plubbingID)
  }
  
  private func fetchMeetingData(plubbingID: String) {
    RecruitmentService.shared.inquireDetailRecruitment(plubbingID: plubbingID)
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          guard let data = model.data else { return }
          owner.setupMeetingData(data: data)
          owner.fetchedMeetingData.onNext(owner.request)
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func setupMeetingData(data: DetailRecruitmentResponse) {
    request.days = data.days
    if data.address.isEmpty {
      request.onOff = .on
    } else {
      request.onOff = .off
      request.placeName = data.placeName
      request.address = data.address
      request.roadAddress = data.roadAddress
      request.positionX = data.placePositionX
      request.positionY = data.placePositionY
    }
    request.peopleNumber = data.curAccountNum
  }
  
  func updateDate(data: MeetingDateCollectionViewCellModel) {
    let dates = dateInputRelay.value // 선택된 요일 ENG 값 배열 (ex: [MON, TUE...])
    let cellDatas = dateCellData.value // collectionView 셀 데이터 (date: 요일, isSelected: 선택 여부)
    
    if data.isSelected { // CASE 1) 선택 해제
      dateInputRelay.accept(dates.filter { $0 != data.date.fromKORToENG() }) // 선택된 요일 값 삭제
      dateCellData.accept(
        cellDatas.map {
          MeetingDateCollectionViewCellModel(
            date: $0.date,
            isSelected: $0.date == data.date ? false : $0.isSelected // 선택된 요일 값만 isSelected false로 변경
          )
        }
      )
    }
    else if data.date == Day.all.kor { // CASE 2) 요일 무관 선택
      dateInputRelay.accept([data.date.fromKORToENG()]) // "요일 무관"만 존재
      dateCellData.accept(
        cellDatas.map {
          MeetingDateCollectionViewCellModel(
            date: $0.date,
            isSelected: $0.date == Day.all.kor ? true : false // "요일 무관"만 isSelected true, 나머지는 false로 변경
          )
        }
      )
    }
    else { // CASE 3) 요일 무관 제외한 요일 선택
      var filterDates = dates.filter { $0 != Day.all.eng } // "요일 무관" 삭제하고,
      filterDates.append(data.date.fromKORToENG()) // 선택된 요일 값 추가
      dateInputRelay.accept(filterDates)
      
      dateCellData.accept(
        cellDatas.map {
          return MeetingDateCollectionViewCellModel(
            date: $0.date,
            isSelected: {
              if $0.date == Day.all.kor { // "요일 무관"은 isSelected false
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
