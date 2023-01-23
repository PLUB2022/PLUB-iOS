//
//  ProfileViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/20.
//

import Foundation

import RxCocoa
import RxSwift

protocol ProfileViewModelType: ProfileViewModel {
  // input
  var nicknameText: AnyObserver<String> { get }
  
  // output
  var isAvailableNickname: Driver<Bool> { get }
  var alertMessage: Driver<String> { get }
}

final class ProfileViewModel: ProfileViewModelType {
  // input
  let nicknameText: AnyObserver<String> // 닉네임 텍스트
  
  // output
  let isAvailableNickname: Driver<Bool> // 닉네임 사용 가능 여부
  let alertMessage: Driver<String>      // 닉네임 관련 알림 문구
  
  private let isAvailableRelay = PublishRelay<Bool>()
  private let alertMessageRelay = PublishRelay<String>()
  private let nicknameSubject = PublishSubject<String>()
  
  private let disposeBag = DisposeBag()
  
  init() {
    nicknameText = nicknameSubject.asObserver()
    isAvailableNickname = isAvailableRelay.asDriver(onErrorDriveWith: .empty())
    alertMessage = alertMessageRelay.asDriver(onErrorDriveWith: .empty())
    bind()
  }
  
  private func bind() {
    nicknameSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, text in
        owner.validate(text: text)
      })
      .disposed(by: disposeBag)
  }
  
  private func validate(text: String) {
    let characterRegex = "[^a-zA-Z가-힣0-9]" // 한글, 영어, 숫자를 제외한 문자를 찾는 정규표현식 (특수문자 찾기용)
    
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
}
