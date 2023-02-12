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
  
  private let disposeBag = DisposeBag()
  private let plubbingID: String
  
  // CellData
  let dateCellData: BehaviorRelay<[MeetingDateCollectionViewCellModel]>
  
  // Input
  let dateInputRelay = BehaviorRelay<[String]>.init(value: .init())
  let onOffInputRelay = BehaviorRelay<OnOff>.init(value: .on)
  let locationInputRelay = BehaviorRelay<Location?>.init(value: nil)
  let peopleNumberRelay = BehaviorRelay<Int>.init(value: .init())
  
  // Output
  let fetchedMeetingData = PublishSubject<EditMeetingInfoRequest>()
  let isBtnEnabled: Driver<Bool>
  
  private let editMeetingRelay = BehaviorRelay(value: EditMeetingInfoRequest())
  
  init(plubbingID: String) {
    self.plubbingID = plubbingID
    
    let dateList = Day.allCases
      .map { $0.kor }
      .map {
        MeetingDateCollectionViewCellModel(
          date: $0,
          isSelected: false
        )
      }
    dateCellData = .init(value: dateList)
    
    isBtnEnabled = dateInputRelay.asDriver()
      .map { !$0.isEmpty }

  }
  
  func fetchMeetingData() {
    RecruitmentService.shared.inquireDetailRecruitment(plubbingID: plubbingID)
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          guard let data = model.data else { return }
          owner.setupMeetingData(data: data)
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func setupMeetingData(data: DetailRecruitmentResponse) {
    let request = EditMeetingInfoRequest(
      days: data.days,
      onOff: data.address.isEmpty ? .on : .off,
      peopleNumber: data.curAccountNum + data.remainAccountNum,
      address: data.address,
      roadAddress: data.roadAddress,
      placeName: data.placeName,
      positionX: data.placePositionX,
      positionY: data.placePositionY
    )
    
    editMeetingRelay.accept(request)

    onOffInputRelay.accept(data.address.isEmpty ? .on : .off)
    peopleNumberRelay.accept(data.curAccountNum + data.remainAccountNum)
    
    let dates = data.days.map { $0.fromKORToENG() }
    dateInputRelay.accept(dates)
    
    let cellDatas = dateCellData.value
    dateCellData.accept(
      cellDatas.map {
        MeetingDateCollectionViewCellModel(
          date: $0.date,
          isSelected: dates.contains($0.date.fromKORToENG())
        )
      }
    )
    
    fetchedMeetingData.onNext(request)
    
    guard !data.address.isEmpty else { return }
    locationInputRelay.accept(
      Location(
        address: data.address,
        roadAddress: data.roadAddress,
        placeName: data.placeName,
        positionX: data.placePositionX,
        positionY: data.placePositionY
      )
    )
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
  
  func requestEditMeeting() {
    MeetingService.shared
      .editMeetingInfo(
        plubbingID: plubbingID,
        request: setupEditMeetingRequest()
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
  
  private func setupEditMeetingRequest() -> EditMeetingInfoRequest{
    print(EditMeetingInfoRequest(
      days: dateInputRelay.value,
      onOff: onOffInputRelay.value,
      peopleNumber: peopleNumberRelay.value,
      address: locationInputRelay.value?.address,
      roadAddress: locationInputRelay.value?.roadAddress,
      placeName: locationInputRelay.value?.placeName,
      positionX: locationInputRelay.value?.positionX,
      positionY: locationInputRelay.value?.positionY
    ))
    return EditMeetingInfoRequest(
      days: dateInputRelay.value,
      onOff: onOffInputRelay.value,
      peopleNumber: peopleNumberRelay.value,
      address: locationInputRelay.value?.address,
      roadAddress: locationInputRelay.value?.roadAddress,
      placeName: locationInputRelay.value?.placeName,
      positionX: locationInputRelay.value?.positionX,
      positionY: locationInputRelay.value?.positionY
    )
  }
}
