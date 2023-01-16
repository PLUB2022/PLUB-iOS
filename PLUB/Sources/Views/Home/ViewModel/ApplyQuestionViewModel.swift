//
//  ApplyQuestionViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import RxSwift
import RxCocoa
import Foundation

protocol ApplyQuestionViewModelType {
  // Input
  var whichQuestion: AnyObserver<QuestionStatus> { get }
  
  // Output
  var allQuestion: Driver<[ApplyQuestionTableViewCellModel]> { get }
  var isActivated: Driver<Bool> { get }
}

class ApplyQuestionViewModel: ApplyQuestionViewModelType {
  private var disposeBag = DisposeBag()
  // Input
  var whichQuestion: AnyObserver<QuestionStatus>
  
  // Output
  var allQuestion: Driver<[ApplyQuestionTableViewCellModel]>
  var isActivated: Driver<Bool>
  
  init() {
    let questions = BehaviorSubject<[ApplyQuestionTableViewCellModel]>(value: [])
    let writingCount = BehaviorSubject<Int>(value: 0)
    let currentQuestion = PublishSubject<QuestionStatus>()
    let isActivating = BehaviorSubject<Bool>(value: false)
    
    self.allQuestion = questions.asDriver(onErrorJustReturn: [])
    self.whichQuestion = currentQuestion.asObserver()
    self.isActivated = isActivating.asDriver(onErrorJustReturn: false)
    
    let entireQuestionCount = questions.map { $0.count }
    
    let plusCount = currentQuestion.distinctUntilChanged()
      .withLatestFrom(writingCount) { ($0, $1) }
      .filter { $0.0.isFilled }
      .map { $0.1 + 1 }
    
    let minusCount = currentQuestion.distinctUntilChanged()
      .withLatestFrom(writingCount) { ($0, $1) }
      .filter { !$0.0.isFilled }
      .map { $0.1 - 1 }
    
    Observable.merge(plusCount, minusCount)
      .bind(to: writingCount)
      .disposed(by: disposeBag)
    
    Observable.combineLatest(writingCount, entireQuestionCount) { ($0, $1) }
      .map { $0.0 == $0.1 }
      .bind(to: isActivating)
      .disposed(by: disposeBag)
    
    questions.onNext([
      .init(id: 1,question: "1. 지원 동기가 궁금해요!"),
      .init(id: 2,question: "2. 당신의 실력은 어느정도?!"),
      .init(id: 3,question: "3. 간단한 자기소개! ")
    ])
  }
}

struct QuestionStatus: Equatable {
  let id: Int
  let isFilled: Bool
  
  static func == (lhs: QuestionStatus, rhs: QuestionStatus) -> Bool {
    return lhs.id == rhs.id && lhs.isFilled == rhs.isFilled
  }
}
