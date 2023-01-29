//
//  MeetingNameViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/16.
//

import RxSwift
import RxCocoa

protocol MeetingNameViewModelType {
  associatedtype Input
  associatedtype Output

  func transform(input: Input) -> Output
}

final class MeetingNameViewModel: MeetingNameViewModelType {
  private let disposeBag = DisposeBag()
  
  private let introduceTitleInputRelay = BehaviorRelay<String>.init(value: .init())
  private let nameTitleInputRelay = BehaviorRelay<String>.init(value: .init())
  
  struct Input {
    let introduceTitleText: Observable<String>
    let nameTitleText: Observable<String>
  }
  
  struct Output {
    let isBtnEnabled: Driver<Bool>
  }
  
  func transform(input: Input) -> Output {
    
    input.introduceTitleText
      .subscribe(onNext: { [weak self] in
        self?.introduceTitleInputRelay.accept($0)
      })
      .disposed(by: disposeBag)
    
    input.nameTitleText
      .subscribe(onNext: { [weak self] in
        self?.nameTitleInputRelay.accept($0)
      })
      .disposed(by: disposeBag)
    
    let isBtnEnabled = Driver.combineLatest(
      introduceTitleInputRelay.asDriver(),
      nameTitleInputRelay.asDriver()
    ) {
      !$0.isEmpty &&
      $0 != "소개하는 내용을 입력해주세요" &&
      !$1.isEmpty &&
      $1 != "우리동네 사진모임"
    }
    
    return Output(
      isBtnEnabled: isBtnEnabled
    )
  }
}
