//
//  ProfileViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/20.
//

import Foundation

import RxCocoa
import RxSwift

final class ProfileViewModel {
  private let disposeBag = DisposeBag()
  
  private let isAvailableRelay = PublishRelay<Bool>()
  private let alertMessageRelay = PublishRelay<String>()
}

// MARK: - Rx Progress

extension ProfileViewModel {
  struct Input {
    // 텍스트필드의 텍스트
    let text: Observable<String>
  }
  
  struct Output {
    // 현재 버튼 체크되어있는 상태
    let isAvailable: Driver<Bool>
    let alertMessage: Driver<String>
  }
  
  func transform(input: Input) -> Output {
    
    input.text
      .withUnretained(self)
      .subscribe(onNext: { owner, text in
        owner.validate(text: text)
      })
      .disposed(by: disposeBag)
    
    return Output(
      isAvailable: isAvailableRelay.asDriver(onErrorJustReturn: false),
      alertMessage: alertMessageRelay.asDriver(onErrorJustReturn: ""))
  }
  
  func validate(text: String) {
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
    
    // TODO: 승헌 - 닉네임 중복 검사 처리
    
    
    
    // Success!
    isAvailableRelay.accept(true)
    alertMessageRelay.accept("사용가능한 닉네임이에요.")
  }
}
