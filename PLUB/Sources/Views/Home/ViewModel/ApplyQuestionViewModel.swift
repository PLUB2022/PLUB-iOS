//
//  ApplyQuestionViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import RxSwift
import RxCocoa
import Foundation

// TODO: 이건준 - combineLatest이용하여 지원질문화면 Active에 따른 isActive 데이터처리해줘야함

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
    let isFillingInQuestion = BehaviorSubject<Bool>(value: false)
    let currentQuestion = PublishSubject<QuestionStatus>()
    let entireQuestionStatus = PublishSubject<[QuestionStatus]>()
    let isActivating = BehaviorSubject<Bool>(value: false)
    
    self.allQuestion = questions.asDriver(onErrorJustReturn: [])
    self.whichQuestion = currentQuestion.asObserver()
    self.isActivated = isActivating.asDriver(onErrorJustReturn: false)
    let entireQuestionCount = questions.map { $0.count }
    
    let questionStatus = questions.map { questionModels in
      questionModels.map { model in
        return QuestionStatus(id: model.id, isFilled: false)
      }
    }
    
//    questionStatus.bind(to: entireQuestionStatus)
//      .disposed(by: disposeBag)
    
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
    
    writingCount.subscribe(onNext: { count in
      print("count = \(count)")
    })
    .disposed(by: disposeBag)
      
      
    
    entireQuestionStatus.subscribe(onNext: { status in
      print("status = \(status)")
    })
    .disposed(by: disposeBag)
    
//    Observable.combineLatest(
//      isFillingInQuestion,
//      currentPositonRow
//    ) { ($0, $1) }
//      .distinctUntilChanged { $0 == $1 }
//      .subscribe(onNext: { isFill, position in
//        print("isFill = \(isFill)")
//        print("position = \(position)")
//      })
//      .disposed(by: disposeBag)
    
//    isFillingInQuestion
//      .distinctUntilChanged()
//      .filter { $0 == true }
//      .withLatestFrom(writingCount.asObservable())
//      .subscribe(onNext: { count in
//          writingCount.onNext(count + 1)
//          print("plus = \(count + 1)")
//        }
//      )
//      .disposed(by: disposeBag)

    questions.onNext([
      .init(id: 1,question: "1. 지원 동기가 궁금해요!"),
      .init(id: 2,question: "2. 당신의 실력은 어느정도?!"),
      .init(id: 3,question: "3. 간단한 자기소개! ")
    ])
  }
}

struct QuestionStatus: Equatable {
  let id: Int
  var isFilled: Bool
  
  mutating func updatedFilledStatus(isFilled: Bool) {
    self.isFilled = isFilled
  }
  
  static func == (lhs: QuestionStatus, rhs: QuestionStatus) -> Bool {
      return lhs.id == rhs.id && lhs.isFilled == rhs.isFilled
  }
}
