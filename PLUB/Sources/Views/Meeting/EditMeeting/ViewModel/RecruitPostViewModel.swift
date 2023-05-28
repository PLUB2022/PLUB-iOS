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
  
  private let disposeBag = DisposeBag()
  private let plubbingID: Int
  
  // Input
  let introduceTitleText: AnyObserver<String>
  let nameTitleText: AnyObserver<String>
  let goalText: AnyObserver<String>
  let introduceText: AnyObserver<String>
  let meetingImage: AnyObserver<UIImage?>
  
  // Output
  let isBtnEnabled: Driver<Bool>
  let fetchedMeetingData = PublishSubject<EditMeetingPostRequest>()
  let successEditQuestion = PublishSubject<Void>()
  
  private let introduceTitleSubject = PublishSubject<String>()
  private let nameTitleSubject = PublishSubject<String>()
  private let goalInputSubject = PublishSubject<String>()
  private let introduceSubject = PublishSubject<String>()
  private let imageInputRelay = BehaviorSubject<UIImage?>(value: nil)
  
  private let editMeetingRelay = BehaviorRelay(value: EditMeetingPostRequest())
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
    
    introduceTitleText = introduceTitleSubject.asObserver()
    nameTitleText = nameTitleSubject.asObserver()
    goalText = goalInputSubject.asObserver()
    introduceText = introduceSubject.asObserver()
    meetingImage = imageInputRelay.asObserver()
   
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
    
    bind()
  }
  
  private func bind() {
    introduceTitleSubject
      .withUnretained(self)
      .compactMap { owner, title in
        owner.editMeetingRelay.value.with {
          $0.title = title
        }
      }
      .bind(to: editMeetingRelay)
      .disposed(by: disposeBag)
    
    nameTitleSubject
      .withUnretained(self)
      .compactMap { owner, name in
        owner.editMeetingRelay.value.with {
          $0.name = name
        }
      }
      .bind(to: editMeetingRelay)
      .disposed(by: disposeBag)
    
    goalInputSubject
      .withUnretained(self)
      .compactMap { owner, goal in
        owner.editMeetingRelay.value.with {
          $0.goal = goal
        }
      }
      .bind(to: editMeetingRelay)
      .disposed(by: disposeBag)
    
    introduceSubject
      .withUnretained(self)
      .compactMap { owner, introduce in
        owner.editMeetingRelay.value.with {
          $0.introduce = introduce
        }
      }
      .bind(to: editMeetingRelay)
      .disposed(by: disposeBag)
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
    let request = EditMeetingPostRequest(
      title: data.title,
      name: data.name,
      goal: data.goal,
      introduce: data.introduce,
      mainImage: data.mainImage
    )
    editMeetingRelay.accept(request)
    fetchedMeetingData.onNext(request)
  }
  
  func editMeetingPost() {
    if let image = try? imageInputRelay.value() {
      requestImageUpload(image: image)
    } else {
      requestEditMeeting(with: editMeetingRelay.value)
    }
  }
  
  private func requestImageUpload(image: UIImage) {
    ImageService.shared.uploadImage(
      images: [image],
      params: UploadImageRequest(type: .plubbingMain)
    )
    .withUnretained(self)
    .subscribe(onNext: { owner, result in
      switch result {
      case .success(let model):
        guard let data = model.data,
              let fileUrl = data.files.first?.fileURL else { return }
        let request = owner.editMeetingRelay.value.with {
          $0.mainImage = fileUrl
        }
        owner.requestEditMeeting(with: request)
        
      default: break// TODO: 수빈 - PLUB 에러 Alert 띄우기
      }
    })
    .disposed(by: disposeBag)
  }
  
  private func requestEditMeeting(with request: EditMeetingPostRequest) {
    RecruitmentService.shared
      .editMeetingPost(
        plubbingID: plubbingID,
        request: request
      )
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          owner.successEditQuestion.onNext(())
        default: break// TODO: 수빈 - PLUB 에러 Alert 띄우기
        }
      })
      .disposed(by: disposeBag)
  }
}
