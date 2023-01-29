//
//  MeetingIntroduceViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/16.
//

import RxSwift
import RxCocoa

protocol MeetingIntroduceViewModelType {
  associatedtype Input
  associatedtype Output

  func transform(input: Input) -> Output
}

final class MeetingIntroduceViewModel: MeetingIntroduceViewModelType {
  private let disposeBag = DisposeBag()
  
  private let goalInputRelay = BehaviorRelay<String>.init(value: .init())
  private let introduceInputRelay = BehaviorRelay<String>.init(value: .init())
  
  struct Input {
    let goalText: Observable<String>
    let introduceText: Observable<String>
  }
  
  struct Output {
    let isBtnEnabled: Driver<Bool>
  }
  
  func transform(input: Input) -> Output {
    
    input.goalText
      .subscribe(onNext: { [weak self] in
        self?.goalInputRelay.accept($0)
      })
      .disposed(by: disposeBag)
    
    input.introduceText
      .subscribe(onNext: { [weak self] in
        self?.introduceInputRelay.accept($0)
      })
      .disposed(by: disposeBag)
    
    let isBtnEnabled = Driver.combineLatest(
      goalInputRelay.asDriver(),
      introduceInputRelay.asDriver()
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
