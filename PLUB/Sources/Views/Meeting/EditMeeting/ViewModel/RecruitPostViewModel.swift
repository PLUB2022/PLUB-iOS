//
//  RecruitPostViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/11.
//

import UIKit

import RxSwift
import RxCocoa

final class RecruitPostViewModel {
  
  private lazy var disposeBag = DisposeBag()
  
  private let introduceTitleSubject = PublishSubject<String>()
  private let nameTitleSubject = PublishSubject<String>()
  private let goalInputSubject = PublishSubject<String>()
  private let introduceSubject = PublishSubject<String>()
  private let imageInputSubject = PublishSubject<UIImage?>()

  // Input
  let introduceTitleText: AnyObserver<String>
  let nameTitleText: AnyObserver<String>
  let goalText: AnyObserver<String>
  let introduceText: AnyObserver<String>
  let meetingImage: AnyObserver<UIImage?>
  
  // Output
  let isBtnEnabled: Driver<Bool>
  let fetchedMeetingData = PublishSubject<EditMeetingRequest>()
  
  private var request = EditMeetingRequest()
  
  init(plubbingID: String) {
    
    introduceTitleText = introduceTitleSubject.asObserver()
    nameTitleText = nameTitleSubject.asObserver()
    goalText = goalInputSubject.asObserver()
    introduceText = introduceSubject.asObserver()
    meetingImage = imageInputSubject.asObserver()
   
    isBtnEnabled = Driver.combineLatest(
      introduceTitleSubject.asDriver(onErrorDriveWith: .empty()),
      nameTitleSubject.asDriver(onErrorDriveWith: .empty()),
      goalInputSubject.asDriver(onErrorDriveWith: .empty()),
      introduceSubject.asDriver(onErrorDriveWith: .empty())
    ) {
      !$0.isEmpty &&
      $0 != "소개하는 내용을 입력해주세요" &&
      !$1.isEmpty &&
      $1 != "우리동네 사진모임" &&
      !$2.isEmpty &&
      $2 != "소개하는 내용을 입력해주세요" &&
      !$3.isEmpty &&
      $3 != "우리동네 사진모임"
    }
    
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
}
