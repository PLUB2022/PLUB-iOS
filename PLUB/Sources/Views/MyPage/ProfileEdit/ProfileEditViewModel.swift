//
//  ProfileEditViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/05.
//

import Foundation
import UIKit

import RxCocoa
import RxSwift

final class ProfileEditViewModel {
  // input
  let nicknameText: AnyObserver<String> // 닉네임 텍스트
  let introduceText: AnyObserver<String> // 소개 텍스트
  let editedImage: AnyObserver<UIImage?> // 변경된 이미지
  let updateButtonTapped: AnyObserver<Void> // 변경 버튼 클릭 이벤트
  
  // output
  let isAvailableNickname: Driver<Bool> // 닉네임 사용 가능 여부
  let alertMessage: Driver<String>      // 닉네임 관련 알림 문구
  let isButtonEnabled: Driver<Bool> // 버튼 활성화 제어
  let successUpdateProfile: Driver<MyInfoResponse> // 프로필 변경 완료
  
  private let nicknameSubject = PublishSubject<String>()
  private let introduceSubject = PublishSubject<String>()
  private let editedImageSubject = BehaviorSubject<UIImage?>(value: nil)
  private let updateButtonSubject = PublishSubject<Void>()
  private let successUpdateProfileSubject = PublishSubject<MyInfoResponse>()
  
  private let isAvailableRelay = PublishRelay<Bool>()
  private let alertMessageRelay = PublishRelay<String>()
  private let disposeBag = DisposeBag()
  
  private(set) var myInfoData: MyInfoResponse // 내정보
  
  init(myInfoData: MyInfoResponse) {
    self.myInfoData = myInfoData
    
    nicknameText = nicknameSubject.asObserver()
    introduceText = introduceSubject.asObserver()
    editedImage = editedImageSubject.asObserver()
    updateButtonTapped = updateButtonSubject.asObserver()
    
    isAvailableNickname = isAvailableRelay.asDriver(onErrorDriveWith: .empty())
    alertMessage = alertMessageRelay.asDriver(onErrorDriveWith: .empty())
    successUpdateProfile = successUpdateProfileSubject.asDriver(onErrorDriveWith: .empty())
    
    isButtonEnabled = Driver.combineLatest(
      introduceSubject.asDriver(onErrorDriveWith: .empty()),
      isAvailableNickname
    ) { introduce, isAvailable in
      !introduce.isEmpty && isAvailable
    }
    
    nicknameSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, text in
        owner.validate(text: text)
      })
      .disposed(by: disposeBag)
    
    updateButtonSubject
      .withLatestFrom(
        Observable.combineLatest(
          nicknameSubject,
          introduceSubject,
          editedImageSubject
        )
      )
      .subscribe(onNext: { [weak self] nickName, introduce, image in
        guard let self = self else { return }
        self.updateMyInfo(
          nickName: nickName,
          introduce: introduce,
          image: image
        )
      })
      .disposed(by: disposeBag)
  }
  
  private func validate(text: String) {
    let characterRegex = "[^a-zA-Z가-힣0-9]" // 한글, 영어, 숫자를 제외한 문자를 찾는 정규표현식 (특수문자 찾기용)
    
    // 2~8자가 아닌 경우
    if text.count < 2 || text.count > 8 {
      isAvailableRelay.accept(false)
      alertMessageRelay.accept("2자에서 8자 사이로 입력해주세요.")
      return
    }
    
    // text에 공백이 존재하는 경우
    if text.range(of: " ") != nil {
      isAvailableRelay.accept(false)
      alertMessageRelay.accept("띄어쓰기를 할 수 없어요.")
      return
    }
    
    // 특수문자가 발생한 경우
    if text.range(of: characterRegex, options: .regularExpression) != nil {
      isAvailableRelay.accept(false)
      alertMessageRelay.accept("특수문자는 사용할 수 없어요.")
      return
    }
    
    // 닉네임 중복 검사
    AccountService.shared.validateNickname(text)
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success:
          owner.isAvailableRelay.accept(true)
          owner.alertMessageRelay.accept("사용가능한 닉네임이에요.")
        case let .requestError(model):
          // 중복인 닉네임일 때
          if model.statusCode == 2060 {
            owner.isAvailableRelay.accept(false)
            owner.alertMessageRelay.accept("이미 사용중인 닉네임이에요.")
          } else {
            owner.isAvailableRelay.accept(false)
            owner.alertMessageRelay.accept("잘못된 값을 입력했어요.")
          }
        // TODO: 승헌 - path error, server error, network error에 따른 alert 처리
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func updateMyInfo(
    nickName: String,
    introduce: String,
    image: UIImage?
  ) {
    if let image = image { // 변경된 이미지 있을 때
      if let prevImageURL = myInfoData.profileImage { // 이전 이미지 존재하는 경우
        updateImage(
          nickName: nickName,
          introduce: introduce,
          deleteURL: prevImageURL,
          image: image
        )
      } else { // 처음 이미지 올리는 경우
        uploadImage(
          nickName: nickName,
          introduce: introduce,
          image: image
        )
      }
    } else { // 변경된 이미지 없을 때
      updateMyInfo(
        request: MyInfoRequest(
          nickname: nickName,
          introduce: introduce,
          profileImage: nil
        )
      )
    }
  }
  
  private func updateMyInfo(request: MyInfoRequest) {
    AccountService.shared.updateMyInfo(request: request)
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          guard let data = model.data else { return }
          owner.successUpdateProfileSubject.onNext(data)
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func uploadImage(
    nickName: String,
    introduce: String,
    image: UIImage
  ) {
    ImageService.shared.uploadImage(
      images: [image],
      params: UploadImageRequest(type: .plubbingMain)
    )
    .withUnretained(self)
    .subscribe(onNext: { owner, result in
      switch result {
      case .success(let model):
        guard let data = model.data,
              let fileUrl = data.files.first?.fileUrl else { return }
        owner.updateMyInfo(
          request: MyInfoRequest(
            nickname: nickName,
            introduce: introduce,
            profileImage: fileUrl
          )
        )
        
      default: break// TODO: 수빈 - PLUB 에러 Alert 띄우기
      }
    })
    .disposed(by: disposeBag)
  }
  
  private func updateImage(
    nickName: String,
    introduce: String,
    deleteURL: String,
    image: UIImage
  ) {
    ImageService.shared.updateImage(
      images: [image],
      params: UpdateImageRequest(type: .plubbingMain, deleteURL: deleteURL)
    )
    .withUnretained(self)
    .subscribe(onNext: { owner, result in
      switch result {
      case .success(let model):
        guard let data = model.data,
              let fileUrl = data.files.first?.fileUrl else { return }
        owner.updateMyInfo(
          request: MyInfoRequest(
            nickname: nickName,
            introduce: introduce,
            profileImage: fileUrl
          )
        )
        
      default: break// TODO: 수빈 - PLUB 에러 Alert 띄우기
      }
    })
    .disposed(by: disposeBag)
  }
}
